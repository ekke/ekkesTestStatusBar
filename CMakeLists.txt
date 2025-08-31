cmake_minimum_required(VERSION 3.16)

project(test_statusbar VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2)

qt_standard_project_setup(REQUIRES 6.9)

# SINGLETONS
set_source_files_properties(AppState.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_executable(apptest_statusbar
    main.cpp
)

qt_add_qml_module(apptest_statusbar
    URI test_statusbar
    VERSION 1.0
    QML_FILES
        Main.qml
        AppState.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(apptest_statusbar PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apptest_statusbar
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

if(ANDROID)
    # OPENSSL
    # https://github.com/KDAB/android_openssl
    # points to OpenSSL installed by QtCreator with Android SDK Tools
    include(/Applications/daten/_android_sdk/tools_6_9_0/android_openssl/android_openssl.cmake)
        add_android_openssl_libraries(apptest_statusbar)
endif()

target_link_libraries(apptest_statusbar
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS apptest_statusbar
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
