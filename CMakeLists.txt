######################################################################
## CMakeLists.txt
## This file is part of the gsAgent compiler.
##
## Integrates agent fetching with CMake build system.
######################################################################

cmake_minimum_required(VERSION 3.16)
project(gsAgents LANGUAGES NONE)

# =============================================================================
# Options for ccmake / CMake GUI
# =============================================================================

# Agent providers to fetch (comma or semicolon separated for GUI)
set(GISMO_AGENT_PROVIDERS "claude;gemini;opencode" CACHE STRING "Agent providers to fetch (e.g. claude;gemini;opencode)")
set_property(CACHE GISMO_AGENT_PROVIDERS PROPERTY STRINGS "claude" "gemini" "opencode" "claude;gemini" "claude;opencode" "gemini;opencode" "claude;gemini;opencode")

# Agent types to fetch
set(GISMO_AGENT_TYPES "agents;commands;skills;rules" CACHE STRING "Agent types to fetch (agents;commands;skills;rules)")
set_property(CACHE GISMO_AGENT_TYPES PROPERTY STRINGS "agents" "commands" "skills" "rules" "agents;commands" "agents;commands;skills" "agents;commands;skills;rules")

# Installation directory for agents (default: <build-dir>/install)
set(GISMO_INSTALL_DIR "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation directory for agent files")

# Force download agents from remote
option(GISMO_AGENTS_FORCE_DOWNLOAD "Force download agents from remote, overwriting local files" OFF)

# =============================================================================
# Include fetch functionality
# =============================================================================

include(cmake/FetchAgents.cmake)

# =============================================================================
# Custom Targets
# =============================================================================

# Helper script to invoke fetch (created at configure time)
# This will be updated by CMake whenever cache changes
set(_fetch_wrapper "${CMAKE_BINARY_DIR}/fetch_wrapper.cmake")
file(WRITE "${_fetch_wrapper}" "
# Read current cache values at build time
file(STRINGS \"\${CMAKE_BINARY_DIR}/CMakeCache.txt\" _cache_lines)
foreach(_line \${_cache_lines})
    if(_line MATCHES \"^GISMO_AGENT_PROVIDERS:STRING=(.*)$\")
        set(GISMO_AGENT_PROVIDERS \"\${CMAKE_MATCH_1}\")
    elseif(_line MATCHES \"^GISMO_AGENT_TYPES:STRING=(.*)$\")
        set(GISMO_AGENT_TYPES \"\${CMAKE_MATCH_1}\")
    elseif(_line MATCHES \"^GISMO_AGENTS_FORCE_DOWNLOAD:BOOL=(.*)$\")
        set(GISMO_AGENTS_FORCE_DOWNLOAD \"\${CMAKE_MATCH_1}\")
    endif()
endforeach()

# Execute fetch with current cache values
set(CMAKE_MODULE_PATH \"${CMAKE_SOURCE_DIR}/cmake\")
include(FetchAgents)
")

# Fetch agents from remote
# Use wrapper script to read cache values at build time
add_custom_target(fetch-agents
    COMMAND ${CMAKE_COMMAND}
        -DGISMO_CMAKE_SOURCE_DIR="${CMAKE_SOURCE_DIR}"
        -DGISMO_CMAKE_BINARY_DIR="${CMAKE_BINARY_DIR}"
        -P "${_fetch_wrapper}"
    COMMENT "Fetching agent instructions for providers: ${GISMO_AGENT_PROVIDERS} types: ${GISMO_AGENT_TYPES}"
)

# Default target depends on fetch-agents
if(NOT TARGET default)
    add_custom_target(default)
    add_dependencies(default fetch-agents)
endif()

# =============================================================================
# Installation
# =============================================================================

# Custom install target (copies from source tree where fetch writes to install dir)
add_custom_target(install-agents
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target fetch-agents
    COMMAND ${CMAKE_COMMAND} -E echo "Installing agents to ${GISMO_INSTALL_DIR}"
)

# Helper script to install agents (created at configure time)
set(_install_script "${CMAKE_BINARY_DIR}/install_agents.cmake")
file(WRITE "${_install_script}" "
# This script copies downloaded agents from build dir to the install directory
# Preserves the hidden directory structure (.claude/, .opencode/, etc.)
foreach(_prov ${GISMO_AGENT_PROVIDERS})
    foreach(_type ${GISMO_AGENT_TYPES})
        set(_src_dir \"${CMAKE_BINARY_DIR}/.\${_prov}/\${_type}\")
        set(_dst_dir \"${GISMO_INSTALL_DIR}/.\${_prov}/\${_type}\")
        if(IS_DIRECTORY \"\${_src_dir}\")
            file(MAKE_DIRECTORY \"\${_dst_dir}\")
            file(GLOB_RECURSE _files RELATIVE \"\${_src_dir}\" \"\${_src_dir}/*\")
            foreach(_file \${_files})
                configure_file(
                    \"\${_src_dir}/\${_file}\"
                    \"\${_dst_dir}/\${_file}\"
                    COPYONLY
                )
            endforeach()
            message(STATUS \"  Installed .\${_prov}/\${_type} (\${_prov}/\${_type}) to \${_dst_dir}\")
        endif()
    endforeach()
endforeach()

# Copy AGENTS.md
if(EXISTS \"${CMAKE_BINARY_DIR}/AGENTS.md\")
    file(MAKE_DIRECTORY \"${GISMO_INSTALL_DIR}\")
    configure_file(
        \"${CMAKE_BINARY_DIR}/AGENTS.md\"
        \"${GISMO_INSTALL_DIR}/AGENTS.md\"
        COPYONLY
    )
    message(STATUS \"  Installed AGENTS.md to ${GISMO_INSTALL_DIR}/AGENTS.md\")
else()
    message(STATUS \"  AGENTS.md not found, skipping\")
endif()
")

# Add command to actually run the install script
add_custom_command(
    TARGET install-agents POST_BUILD
    COMMAND ${CMAKE_COMMAND} -P "${_install_script}"
    COMMENT "Copying agents to ${GISMO_INSTALL_DIR}"
)

# =============================================================================
# Cleanup
# =============================================================================

# Clean downloaded agents but keep installation
add_custom_target(clean-agents
    COMMAND ${CMAKE_COMMAND} -E echo "Cleaning downloaded agents from build dir..."
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}/.claude"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}/.gemini"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}/.opencode"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}/.other"
    COMMAND ${CMAKE_COMMAND} -P "${CMAKE_SOURCE_DIR}/cmake/CleanAgents.cmake"
    COMMAND ${CMAKE_COMMAND} -E remove "${CMAKE_BINARY_DIR}/AGENTS.md"
    COMMAND ${CMAKE_COMMAND} -E echo "Done - temporary downloads removed"
)

# =============================================================================
# Status messages
# =============================================================================

message(STATUS "")
message(STATUS "=== gsAgents Configuration ===")
message(STATUS "Providers: ${GISMO_AGENT_PROVIDERS}")
message(STATUS "Types: ${GISMO_AGENT_TYPES}")
message(STATUS "Install directory: ${GISMO_INSTALL_DIR}")
message(STATUS "Force download: ${GISMO_AGENTS_FORCE_DOWNLOAD}")
message(STATUS "")
message(STATUS "Targets:")
message(STATUS "  cmake --build . --target fetch-agents   # Download agents")
message(STATUS "  cmake --build . --target install-agents # Install agents to ${GISMO_INSTALL_DIR}")
message(STATUS "  cmake --build . --target clean-agents   # Remove temporary downloads (keeps installed agents)")
message(STATUS "")
message(STATUS "Configuration options (use ccmake or cmake -D<option>=<value>):")
message(STATUS "  -DGISMO_AGENT_PROVIDERS=<provs>   # Set providers to fetch")
message(STATUS "  -DGISMO_AGENT_TYPES=<types>      # Set types to fetch")
message(STATUS "  -DGISMO_INSTALL_DIR=<path>        # Set install directory")
message(STATUS "  -DGISMO_AGENTS_FORCE_DOWNLOAD=ON # Force re-download agents")
