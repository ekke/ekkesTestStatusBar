// Main.qml   (apptest_statusbar)

// (c) 2025 Ekkehard Gentz (ekke) - Independent - Rosenheim Germany
// Qt Champion 2016 | 2024
// @ekkescorner.bsky.social
// @ekkescorner (X - aka Twitter)
// @ekke (Qt Discord Server)
// LinkedIn: http://linkedin.com/in/ekkehard/
// GitHub: https://github.com/ekke
// Qt6 blog: https://ekkesapps.wordpress.com/

// requires Qt 6.9.2+
// 2025-09-05

// This App is a playground to test Qt SafeArea 6.9 behavior
// Download from GitHub: https://github.com/ekke/ekkesTestStatusBar
// Documentation and screenshots: https://t1p.de/ekkeStatusBar

// Important: Please read at first:
//   Qt Docs  Safe Areas and ApplicatiionWindow:
//            https://doc.qt.io/qt-6/qml-qtquick-safearea.html
//            https://doc.qt.io/qt-6/qml-qtquick-controls-applicationwindow.html
//   QtBlog:  https://www.qt.io/blog/expanded-client-areas-and-safe-areas-in-qt-6.9

// Disclaimer
// The design of the Safe Areas in Qt Quick is that the safe area of a child item is
// affected by the position of its parent items. Ie, if the parent accounts for safe
// areas by laying out all of its children within the safe area, the child items reflect
// a safe area of 0.
// Reducing the safe area query to a single top level AppState loses this feature.
// Why using single top level SafeArea margins ?
// ekke has 15+ mobile business apps, some grown over 8+ years with hundreds of Pages etc.
// ekke already implemented an own way to get SafeAreas from top level years ago.
// This worked for iOS, but not for Android.
// Now with Qt 6.9 Qt provides a much better and more intelligent way for Controls
// to know about their Safe Areas and for new Apps ekke will go this modern way.
// But for now – all existing apps must be ported from 6.7 QMake to 6.9 CMake and
// multimedia to ffmpeg and trying to get rid of linter warnings …
// So as first step ekke will use the new SafeAreas for Android and iOS, but only
// from top level. Goal for this 1st step: simply do a find and replace to get the
// top level values from QML SafeAreas instead of previous C++ Singleton.
// Take a look at 'PopupB' below, where we compare SafeArea values from top
// vs built-in attached properties.

// Attention: You can change Material colors and stylehints using Menu 'Material'
//            And from 'Drawer' you can choose different ways to colorize
//            Both together sometimes causes 'Material' color changes not to work
//            Using another colorization from Drawer or restarting App helps
//            Have not spend time on this, because these changes aren't under
//            control from user in ekkes apps, so no real-life-scenarios ;-)


pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: appWindow
    visible: true
    width: 400
    height: 800

    // S I Z E   A N D   O R I E N T A T I O N
    // QML Singleton AppState has no access to Screen.orientation
    // or ApplicationWindow width and height
    // We need these values from other Pages, Popups,...
    // So we watch it here and set the corresponding values in AppState
    onWidthChanged: {
        AppState.appWidth = width
    }
    onHeightChanged: {
        AppState.appHeight = height
    }
    // Portrait Qt.PortraitOrientation: 1
    // Landscape Qt.LandscapeOrientation: 2
    // Portrait Invers Qt.InvertedPortraitOrientation: 4
    // Landscape Invers Qt.InvertedLandscapeOrientation: 8
    // Hint: on iOS inverted is only working on 6.9.2+
    // see https://bugreports.qt.io/browse/QTBUG-137249
    Screen.onOrientationChanged: {
        console.log("appWindow Screen.Orientation Changed: ",
                    Screen.orientation)
        AppState.appOrientation = Screen.orientation
    }

    // F L A G S
    // NoTitleBarBackgroundHint needed for macOS
    // don't forget to set QT.Window
    // see discussions at https://bugreports.qt.io/browse/QTBUG-135808
    flags: Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint

    // S A F E    A R E A
    // see also discussions about Expanded Client Areas:
    // https://bugreports.qt.io/browse/QTBUG-135808
    onSafeAreaMarginsChanged: {
        console.log("appWindow onSafeAreaMarginsChanged")
        safeAreaTimer.start()
    }
    // without using the timer we won't get correct SafeArea margins
    // when rotating the device on Android or iOS
    Timer {
        id: safeAreaTimer
        repeat: false
        interval: 200
        onTriggered: {
            appWindow.updateSafeArea()
        }
    } // safeAreaTimer

    // C O N F I G   A N D   S E T T I N G S

    // MATERIAL configuration
    // In ekkes business apps, the theme is always Material.Light
    // and Material.primary / accent are fixed
    // so user doesn't change these

    // In this Test App initially we set for the system StatusBar
    // Application.styleHints.colorScheme = Qt.ColorScheme.Dark
    // and our Material.primary as Material.Teal, so we need
    // the white textcolor
    // see below: Component.onCompleted initializes and sets StyleHints
    // For Tests you can switch the scheme and change Material.primary / accent
    // see materialButton and myMaterialMenu below

    property int myTheme: Material.Light
    property int myPrimaryColor: Material.Teal
    property int myAccentColor: Material.DeepOrange
    property int myStatusbarCholorScheme : Qt.ColorScheme.Dark

    // MATERIAL
    Material.theme: myTheme
    Material.primary: myPrimaryColor
    Material.accent: myAccentColor

    // COLORIZE non safe areas
    // Hint: header toolbar uses default background Material.primaryColor
    // see below headerToolbarBackground HowTo set Toolbar different to StatusBar

    // nonSafeAreaStatusBarColor only is in-use if you don't have a header Toolbar
    // per ex. with TabBar or custom toolbars or 'none'
    // with ToolBar in header we can set background different to StatusBar
    property color headerToolBarColor: Qt.lighter(Material.primaryColor, 1.1)

    // Our defaults will colorize all non Safe Areas same:
    property color nonSafeAreaStatusBarColor: Material.primaryColor
    property color nonSafeAreaBottomColor: Material.primaryColor
    property color nonSafeAreaLeftColor: Material.primaryColor
    property color nonSafeAreaRightColor: Material.primaryColor

    // TOOLBAR, TABBAR or nothing
    // a simple switch to test different situations / configurations
    // perhaps later we'll add more...
    // see headerLoader and footerLoader below
    // "none" | "toolbar" | "tabbar"
    property string headerType: "toolbar"// "toolbar" // "tabbar" // "none" //
    // "none" | "toolbar"
    property string footerType: "toolbar"// "toolbar" // "none"

    // PADDINGS
    // set one or more paddings to 0,
    // if you need access to the non safe areas
    // then you're responsible to respect non safe areas ...
    // see theDrawer below and also use of ListView at QtBlog
    // https://www.qt.io/blog/expanded-client-areas-and-safe-areas-in-qt-6.9
    // if you rely on all values from SafeArea without changes
    // you can leave the paddings as-is
    // if you adjust the reported values as I do in AppState (QML Singleton)
    // calculate the paddings:
    topPadding: AppState.safeAreaTop +
                ( headerType === "toolbar" ? 48
                : headerType === "tabbar" ? 48
                : 0 )
    bottomPadding: AppState.safeAreaBottom +
                ( footerType === "toolbar" ? 48
                : 0 )
    leftPadding: AppState.safeAreaLeft
    rightPadding: AppState.safeAreaRight

    // Hint: In Android Portrait the NavigationBar is part of SafeAreaBottom
    // and in Landscape SafeAreaLeft or Right
    // ATM no special handling here

    // B A C K G R O U N D
    // we don't need to do anything with the background,
    // if a TabBar Control is used and the System StatusBar
    // should be colorized and use same background.

    // expandedClientAreasBackground is the background of
    // the expanded area covering StatusBar, headerToolBar
    // and all non-Safe-Areas on Left, Right, Bottom
    background: Rectangle {
        id: expandedClientAreasBackground

        // non-safe area: System StatusBar
        // you must colorize System StatusBar by yourself if no headerToolBar used
        // using a ToolBar in header the ToolBar is responsible
        // to colorize ToolBar and SystemStatusBar (see headerToolbarBackground)
        // Hint: on ios in Landscape there's no SystemStatusBar
        Rectangle {
            id: nonSafeStatusBarBackground
            width: parent.width
            height: AppState.safeAreaTop
            color: appWindow.nonSafeAreaStatusBarColor
        } // nonSafeStatusBarBackground

        // bottom non-safe area
        // probably not on Android in Landscape
        // Android in Portrait shows virtual keys
        // on ios at bottom: always the line to drag the App
        Rectangle {
            id: nonSafeBottomBackground
            anchors.bottom: parent.bottom
            width: parent.width
            height: AppState.safeAreaBottom
            color: appWindow.nonSafeAreaBottomColor
        } // nonSafeBottomBackground

        // left side non-safe area
        // normally only visible in landscape
        Rectangle {
            id: nonSafeLeftBackground
            anchors.top: parent.top
            anchors.topMargin: AppState.safeAreaTop
            anchors.left: parent.left
            width: AppState.safeAreaLeft
            height: parent.height - AppState.safeAreaTop - AppState.safeAreaBottom
            color: appWindow.nonSafeAreaLeftColor
        } // nonSafeLeftBackground

        // right side non-safe area
        // normally only visible in landscape
        Rectangle {
            id: nonSafeRightBackground
            anchors.top: parent.top
            anchors.topMargin: AppState.safeAreaTop
            anchors.right: parent.right
            width: AppState.safeAreaRight
            height: parent.height - AppState.safeAreaTop - AppState.safeAreaBottom
            color: appWindow.nonSafeAreaRightColor
        } // nonSafeRightBackground

        // adjust position, size and colors of Rectangles above to fit into your design
    } // expandedClientAreasBackground rectangles

    // H E A D E R
    // We have a ToolBar or TabBar or nothing. you can switch from Drawer

    // TOOLBAR HEADER
    // ToolBar Control by magic extends height and covers System StatusBar
    // so it's not so easy to set colors different
    Component {
        id: headerToolBarComponent
        ToolBar {
            id: headerToolBar
            position: ToolBar.Header
            // Background of Toolbar including System Statusbar
            // by default is Material.primary
            // In this example we want to colorize
            // the header ToolBar slightly lighter
            background: Rectangle {
                id: headerToolbarBackground
                anchors.bottom: parent.bottom
                width: parent.width
                height: 48
                color: appWindow.headerToolBarColor
            } // headerToolbarBackground
            Row {
                ToolButton {
                    text: "Tool A"
                    onClicked: {
                        // do something
                    }
                }
                ToolButton {
                    text: "Tool B"
                    onClicked: {
                        // do something
                    }
                }
                ToolButton {
                    text: "Tool C"
                    onClicked: {
                        // do something
                    }
                }
                Label {
                    topPadding: 16
                    leftPadding: 24
                    text: "Titel: Test StatusBar"
                }
            }
         }// headerToolBar
    } // headerToolBarComponent

    // TABBAR HEADER
    // Qt 6.9.2: TabBar Control does not cover System StatusBar as ToolBar does
    // We colorize System StatusBar from nonSafeStatusBarBackground
    // and we colorize TabBar something lighter
    Component {
        id: headerTabBarComponent
        TabBar {
            id: headerTabBar
            position: TabBar.Header
            width: AppState.maxSafeWidth // parent.width
            anchors.top: parent.top
            anchors.topMargin: AppState.safeAreaTop
            anchors.left: parent.left
            anchors.leftMargin: AppState.safeAreaLeft
            anchors.right: parent.right
            anchors.rightMargin: AppState.safeAreaRight
            background:
                Rectangle {
                color: Qt.lighter( Material.primaryColor, 1.8)
            }
            TabButton {
                text: "TAB A"
                onClicked: {
                    // do something
                }
            }
            TabButton {
                text: "TAB B"
                onClicked: {
                    // do something
                }
            }
            TabButton {
                text: "TAB C"
                onClicked: {
                    // do something
                }
            }
        }// headerTabBar
    } // headerTabBarComponent

    // HEADER LOADER
    header: Loader {
        id: headerLoader
        active: appWindow.headerType !== "none"
        sourceComponent: appWindow.headerType === "toolbar" ? headerToolBarComponent
                        : appWindow.headerType === "tabbar" ? headerTabBarComponent
                        : null
    } // headerLoader

    // F O O T E R
    // We have a customized Footer ToolBar or nothing
    // You can test from Drawer

    // TOOLBAR FOOTER
    Component {
        id: footerToolBarComponent
        ToolBar {
            id: footerToolBar
            position: ToolBar.Footer
            // default ToolBar  background is Material.primary
            // we make it slightly ligther
            background: Rectangle {
                height: 48
                width: AppState.maxSafeWidth
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppState.safeAreaBottom
                color: Qt.lighter(Material.backgroundColor, 1.3)
            }
            // Our Bottom ToolBar does not cover left/right non-safe areas
            // remove the Insets if you want to span complete width
            leftInset: AppState.safeAreaLeft
            rightInset: AppState.safeAreaRight
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 36
                anchors.bottom: parent.bottom
                Material.foreground: Material.primaryTextColor

                // Pops all Pages without the first one from StackView
                ToolButton {
                    width: (AppState.maxSafeWidth-72) / 5
                    text: "Home"
                    onClicked: {
                        // we go back to the root of StackView
                        if(theStackView.depth > 1) {
                            theStackView.popToIndex(0)
                        }
                    }
                }

                ToolButton {
                    width: (AppState.maxSafeWidth-72) / 5
                    text: "One"
                    onClicked: {
                        // do something
                    }
                }
                ToolButton {
                    width: (AppState.maxSafeWidth-72) / 5
                    text: "Two"
                    onClicked: {
                        // do something
                    }
                }
                ToolButton {
                    width: (AppState.maxSafeWidth-72) / 5
                    text: "Three"
                    onClicked: {
                        // do something
                    }
                }
                ToolButton {
                    width: (AppState.maxSafeWidth-72) / 5
                    text: "Four"
                    onClicked: {
                        // do something
                    }
                }
            }
         }// footerToolBar
    } // footerToolBarComponent

    // FOOTER LOADER
    footer: Loader {
        id: footerLoader
        active: appWindow.footerType !== "none"
        sourceComponent: appWindow.footerType === "toolbar" ? footerToolBarComponent
                        : null
    } // footerLoader

    // D R A W E R
    // Test different situations, colors, configurations clicking Drawer Buttons
    // Normaly Drawer in ekkes apps navigates thru app features
    Drawer {
        id: theDrawer
        z: 1
        width: 240
        height: AppState.appHeight
        // set paddings to 0, because some parts should be colorized
        // we want the Drawer perfectly fit into StatusBar and Footer SafeAreas
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0

        // DRAWER TITLE and STATUSBAR
        Rectangle {
            id: drawerTitleBackground
            anchors.top: parent.top
            // curios: there was a white border at right side without +1
            width: parent.width+1
            height: AppState.safeAreaTop+48
            color: appWindow.nonSafeAreaStatusBarColor
            Label {
                id: drawerTitle
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 36
                text: "ekke's StatusBar Test"
                color: appWindow.myStatusbarCholorScheme
                       === Qt.ColorScheme.Light? "black" : "white"
            } // drawerTitle
        } // drawerTitleBackground

        // DRAWER BOTTOM
        Rectangle {
            id: drawerBottomBackground
            anchors.bottom: parent.bottom
            // curios: there was a white border at right side without +1
            width: parent.width+1
            height: AppState.safeAreaBottom
            color: appWindow.nonSafeAreaBottomColor
        } // drawerBottomBackground

        // FLICKABLE WITH BUTTONS
        Flickable {
            id: drawerFlickable
            contentHeight: drawerContentColumn.height
                           +drawerTitleBackground.height
                           +drawerBottomBackground.height
                           +16
            anchors.fill: parent
            clip: true
            ColumnLayout {
                id: drawerContentColumn
                anchors.top: parent.top
                anchors.topMargin: AppState.safeAreaTop+48+16
                anchors.left: parent.left
                anchors.leftMargin: AppState.safeAreaLeft+24
                anchors.right: parent.right
                // don't set bottomMargin, scrolling in Landscape
                // on Android can become problematic
                focus: false
                property int buttonWidth: theDrawer.width
                                          - AppState.safeAreaLeft-24-24
                Label {
                    text: "Header"
                    color: Material.accentColor
                }
                // No Header ToolBar or TabBar
                ToolButton {
                    text: "None"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerType = "none"
                        theDrawer.close()
                    }
                }
                // Header with ToolBar
                ToolButton {
                    text: "ToolBar"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerType = "toolbar"
                        theDrawer.close()
                    }
                }
                // Header with TabBar
                ToolButton {
                    text: "TabBar"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerType = "tabbar"
                        theDrawer.close()
                    }
                }
                Label {
                    text: "Footer"
                    color: Material.accentColor
                }
                // Footer without ToolBar
                ToolButton {
                    text: "None"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.footerType = "none"
                        theDrawer.close()
                    }
                }
                // Footer with ToolBar
                ToolButton {
                    text: "ToolBar"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.footerType = "toolbar"
                        theDrawer.close()
                    }
                }
                Label {
                    text: "Colors"
                    color: Material.accentColor
                }
                // All non SafeAreas with Material.primaryColor
                ToolButton {
                    text: "Same"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerToolBarColor = Material.primaryColor
                        appWindow.nonSafeAreaStatusBarColor = Material.primaryColor
                        appWindow.nonSafeAreaBottomColor = Material.primaryColor
                        appWindow.nonSafeAreaLeftColor = Material.primaryColor
                        appWindow.nonSafeAreaRightColor = Material.primaryColor
                        theDrawer.close()
                    }
                }
                // In Landscape Left/Right Safe Areas not colorized
                ToolButton {
                    text: "No L/R"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerToolBarColor = Material.primaryColor
                        appWindow.nonSafeAreaStatusBarColor = Material.primaryColor
                        appWindow.nonSafeAreaBottomColor = Material.primaryColor
                        appWindow.nonSafeAreaLeftColor = Material.backgroundColor
                        appWindow.nonSafeAreaRightColor = Material.backgroundColor
                        theDrawer.close()
                    }
                }
                // To distinguish all the different non Safe Areas,
                // all are colorized different
                ToolButton {
                    text: "Test"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerToolBarColor = Qt.lighter(Material.primaryColor, 1.1)
                        appWindow.nonSafeAreaStatusBarColor = Material.primaryColor
                        appWindow.nonSafeAreaBottomColor = Material.accentColor
                        appWindow.nonSafeAreaLeftColor = Material.color(Material.Lime)
                        appWindow.nonSafeAreaRightColor = Material.color(Material.LightBlue)
                        theDrawer.close()
                    }
                }
                // Bottom non Safe Area not colorized
                ToolButton {
                    text: "No Bottom"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerToolBarColor = Qt.lighter(Material.primaryColor, 1.1)
                        appWindow.nonSafeAreaStatusBarColor = Material.primaryColor
                        appWindow.nonSafeAreaBottomColor = Material.backgroundColor
                        appWindow.nonSafeAreaLeftColor = Material.primaryColor
                        appWindow.nonSafeAreaRightColor = Material.primaryColor
                        theDrawer.close()
                    }
                }
                // SystemBar and Bottom Safe Areas: Material.primaryColor
                // In landscape left/right Areas with color similar to Material.backgroundColor
                ToolButton {
                    text: "Light"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerToolBarColor = Qt.lighter(Material.primaryColor, 1.1)
                        appWindow.nonSafeAreaStatusBarColor = Material.primaryColor
                        appWindow.nonSafeAreaBottomColor = Material.primaryColor
                        appWindow.nonSafeAreaLeftColor = Qt.darker(Material.backgroundColor, 1.1)
                        appWindow.nonSafeAreaRightColor = Qt.darker(Material.backgroundColor, 1.1)
                        theDrawer.close()
                    }
                }
                // Only SystemBar colorized
                ToolButton {
                    text: "No Bottom/L/R"
                    Layout.minimumWidth: drawerContentColumn.buttonWidth
                    onClicked: {
                        appWindow.headerToolBarColor = Material.primaryColor
                        appWindow.nonSafeAreaStatusBarColor = Material.primaryColor
                        appWindow.nonSafeAreaBottomColor = Material.backgroundColor
                        appWindow.nonSafeAreaLeftColor = Material.backgroundColor
                        appWindow.nonSafeAreaRightColor = Material.backgroundColor
                        theDrawer.close()
                    }
                }
            } // drawerContentColumn
            ScrollIndicator.vertical: ScrollIndicator{}
        } // drawerFlickable

    }// theDrawer

    // C O N T E N T   ( S T A C K V I E W )
    StackView {
        id: theStackView
        anchors.fill: parent
        initialItem: appPageComponent
    } // theStackView

    // INITIAL PAGE
    // to make it simple also used to push more pages on top of StackView
    Component {
        id: appPageComponent
        Page {
            id: appPage

            // BACKGROUND
            background: Rectangle {
                id: appPageBackground
                color: Material.background
            } // appPageBackground

            // TEST: TopLeft and BottomRight Corner detected ?
            Rectangle {
                id: topLeftMarker
                anchors.top: parent.top
                anchors.left: parent.left
                width: 40
                height: 40
                color: "red"
            } // topLeftMarker
            Rectangle {
                id: bottomRightMarker
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 40
                height: 40
                color: "red"
            } // bottomRightMarker

            // Test xxl menu
            Button {
                id: xxlButton
                anchors.left: topLeftMarker.right
                anchors.leftMargin: 24
                anchors.top: topLeftMarker.top
                anchors.topMargin: 24
                text: "Menu XXL"
                onClicked: {
                    xxlMenu.open()
                }
            }

            Button {
                id: openDrawerButton
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 24
                text: "Open Drawer"
                visible: theDrawer.position === 0.0
                onClicked: {
                    theDrawer.open()
                }
            } // openDrawerButton

            Button {
                id: materialButton
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.bottom: openDrawerButton.top
                anchors.bottomMargin: 24
                text: "Material"
                onClicked: {
                    myMaterialMenu.parent = materialButton
                    myMaterialMenu.open()
                }
            } // materialButton

            Column {
                id: pageColumn
                anchors.centerIn: parent
                spacing: 8
                Text {
                    text: "safeTop/Bottom/Left/Right: " + AppState.safeAreaTop + "/"
                          + AppState.safeAreaBottom + "/" + AppState.safeAreaLeft
                          + "(" + AppState.safeAreaLeftOrigin + ")" + "/"
                          + AppState.safeAreaRight + "("
                          + AppState.safeAreaRightOrigin + ")"
                }
                Text {
                    text: "isLandscape / Inverted: " + AppState.isLandscape + " / "
                          + AppState.isLandscapeInverted
                }
                Text {
                    text: "appWindowWidth / Height: " + AppState.appWidth + " / "
                          + AppState.appHeight
                }
                Text {
                    text: " thisPageWidth / Height: " + appPage.width + " / "
                          + appPage.height
                }
                Text {
                    text: "maxSafeWidth / Height: " + AppState.maxSafeWidth
                          + " / " + AppState.maxSafeHeight
                }
                Text {
                    text: "depth:" + theStackView.depth + " / depth 2: Push SwipeView"
                }

                Row {
                    id: buttonRow
                    Button {
                        text: "Push"
                        onClicked: {
                            // PUSH SwipeView or Page
                            if(theStackView.depth === 2) {
                                theStackView.pushItem(swipeViewPageComponent)
                            } else {
                                theStackView.pushItem(appPageComponent)
                            }
                        }
                    }
                    Button {
                        enabled: theStackView.depth > 1
                        text: "Pop"
                        onClicked: {
                            theStackView.popCurrentItem()
                        }
                    }
                    Button {
                        id: popupButton
                        text: "Popup"
                        onClicked: {
                            myPopupMenu.parent = popupButton
                            myPopupMenu.open()
                        }
                    }
                } // buttonRow
            } // pageColumn
        } // appPage
    } // appPageComponent
    // M E N U
    // XXL MENU
    Menu {
        id: xxlMenu
        // respects the safe area margins from ApplicationWindow
        // see https://bugreports.qt.io/browse/QTBUG-139695
        topMargin: AppState.safeAreaTop
        bottomMargin: AppState.safeAreaBottom
        MenuItem {
            text: "the first"
        }
        Repeater {
            id: myRepeater
            model: 30
            MenuItem {
                text: "test"
            }
        }
        MenuItem {
            text: "the last"
        }
    } // xxlMenu


    Menu {
        id: myPopupMenu
        width: 360
        // we have to set bottomMargin to avoid Menu overlapping
        // with bottom SafeArea, when in Landscape
        bottomMargin: AppState.isLandscape? AppState.safeAreaBottom : 0
        MenuItem {
            text: "Popup A (x,y fix)"
            onClicked: {
                myPopupA.open()
                myPopupMenu.close()
            }
        }
        MenuItem {
            text: "Popup B (Content in SafeArea)"
            onClicked: {
                myPopupB.open()
                myPopupMenu.close()
            }
        }
        MenuItem {
            text: "Popup C (Content oberlaps UnSafe Areas)"
            onClicked: {
                myPopupC.open()
                myPopupMenu.close()
            }
        }
    } // myPopupMenu
    Menu {
        id: myMaterialMenu
        width: 260
        // we have to set bottomMargin to avoid Menu overlapping
        // with bottom SafeArea
        bottomMargin: AppState.safeAreaBottom
        // default for this test app
        MenuItem {
            text: "Teal+DeepOrange (Dark)"
            onClicked: {
                appWindow.myPrimaryColor = Material.Teal
                appWindow.myAccentColor = Material.DeepOrange
                appWindow.myStatusbarCholorScheme = Qt.ColorScheme.Dark
                styleHintsTimer.start()
                myMaterialMenu.close()
            }
        }
        // test for Light
        MenuItem {
            text: "Yellow+Blue (Light)"
            onClicked: {
                appWindow.myPrimaryColor = Material.Yellow
                appWindow.myAccentColor = Material.Blue
                appWindow.myStatusbarCholorScheme = Qt.ColorScheme.Light
                styleHintsTimer.start()
                myMaterialMenu.close()
            }
        }
        // default from https://doc.qt.io/qt-6/qtquickcontrols-material.html
        MenuItem {
            text: "Indigo+Pink (Dark)"
            onClicked: {
                appWindow.myPrimaryColor = Material.Indigo
                appWindow.myAccentColor = Material.Pink
                appWindow.myStatusbarCholorScheme = Qt.ColorScheme.Dark
                styleHintsTimer.start()
                myMaterialMenu.close()
            }
        }
        // Test Blue and Orange
        MenuItem {
            text: "Blue+Orange (Dark)"
            onClicked: {
                appWindow.myPrimaryColor = Material.Blue
                appWindow.myAccentColor = Material.Orange
                appWindow.myStatusbarCholorScheme = Qt.ColorScheme.Dark
                styleHintsTimer.start()
                myMaterialMenu.close()
            }
        }
        // Test Lime and Brown
        MenuItem {
            text: "Lime+Brown (Light)"
            onClicked: {
                appWindow.myPrimaryColor = Material.Lime
                appWindow.myAccentColor = Material.Brown
                appWindow.myStatusbarCholorScheme = Qt.ColorScheme.Light
                styleHintsTimer.start()
                myMaterialMenu.close()
            }
        }

    } // myMaterialMenu

    // P O P U P S
    // A simple small Popup with fixed size and position
    Popup {
        id: myPopupA
        x: 100
        y: 100
        width: 200
        height: 300
        modal: true
        focus: true
        parent: Overlay.overlay
        contentItem: Text {
            text: "Content Popup A\nx:100, y:100,\nwidth: 200, height:300"
        }
    } // myPopupA

    // This Popup uses all available Screensize without all the NonSafe Areas

    // TopLevel SafeArea (QML Singleton) vs Qt built-in SafeAreas (parent knows about)
    //   From content Text you can compare the SafeArea values from QML Singleton AppState
    //   and from Popup's parent (Overlay.overlay) the attached properties SafeArea margins
    //   on Android in Portrait and Landscape it's the same
    //   on iOS in Portrait it's the same, but in Landscape it's different, because
    //   we have changed the side, where no notch is to 24
    // Also take a look at Popup's width and height where we use covenient values
    //   maxSafeWidth and maxSafeHeight from AppState
    Popup {
        id: myPopupB
        x: AppState.safeAreaLeft
        y: AppState.safeAreaTop
        width: AppState.maxSafeWidth
        height: AppState.maxSafeHeight
        modal: true
        focus: true
        parent: Overlay.overlay
        contentItem: Text {
            id: contentTextB
            text: "Safe Content Popup B\n\nx:SafeAreaLeft, y:SafeAreaTop\nwidth and height respects Safe Areas\n\nworks in Portrait and Landscape\n\n"
                + "AppState values:\nLeft :"+AppState.safeAreaLeft+" Top: "+AppState.safeAreaTop
                + " Right: "+AppState.safeAreaRight+" Bottom: "+AppState.safeAreaBottom
                + "\n\nSafeArea Margins from Overlay:\n"+myPopupB.parent.SafeArea.margins
            Button {
                anchors.bottom: contentTextB.bottom
                text: "Close"
                onClicked: {
                    myPopupB.close()
                }
            }
        } // contentTextB
        background: Rectangle {
            color: Material.color(Material.LightGreen)
        }
    } // myPopupB

    // this Popup shopws HowTo get access to all areas,
    // even if the StackView provides less space to pushed Pages
    Popup {
        id: myPopupC
        x: 0
        y: 0
        width: AppState.appWidth
        height: AppState.appHeight
        modal: true
        focus: true
        parent: Overlay.overlay
        contentItem: Text {
            id: contentTextC
            anchors.top: parent.top
            anchors.topMargin: AppState.safeAreaTop
            horizontalAlignment: Qt.AlignHCenter
            text: "Content Popup C\nOverlaps all UnSafe Areas\nPortrait and Landscape"
            Button {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppState.safeAreaBottom+AppState.safeAreaTop
                anchors.left: parent.left
                anchors.leftMargin: AppState.safeAreaLeft
                text: "Close"
                onClicked: {
                    myPopupC.close()
                }
            }
        } // contentTextC
        background: Rectangle {
            color: Material.color(Material.LightBlue)
        }
    } // myPopupC

    // SWIPEVIEW
    // can be pushed on StackView if depth is 2
    Component {
        id: swipeViewPageComponent
        Page {
            id: swipeViewPage
            SwipeView {
                id: swipeView
                currentIndex: 1
                anchors.fill: parent
                Repeater {
                    model: 3
                    Pane {
                        width: SwipeView.view.width
                        height: SwipeView.view.height
                        Column {
                            spacing: 40
                            width: parent.width
                            Label {
                                width: parent.width
                                wrapMode: Label.Wrap
                                horizontalAlignment: Qt.AlignHCenter
                                text: "S W I P E to left or right. There are 3 Pages. Take a look at PageIndicator at bottom"
                            } // label
                            Row {
                                id: buttonRow
                                Button {
                                    text: "Push"
                                    onClicked: {
                                        theStackView.pushItem(appPageComponent)
                                    }
                                }
                                Button {
                                    enabled: theStackView.depth > 1
                                    text: "Pop"
                                    onClicked: {
                                        theStackView.popCurrentItem()
                                    }
                                }
                            } // buttonRow
                        } // column
                    } // pane
                } // repeater
            } // swipeView
            PageIndicator {
                count: swipeView.count
                currentIndex: swipeView.currentIndex
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            } // pageIndicator
        } // swipeViewPage
    } // swipeViewPageComponent


    // F U N C T I O N S

    // switching styleHint doesn't work reliable without the timer
    // curios: switch from Dark (white text) to Light (black text)
    // works well for Statusbar and ToolBar
    // switch from Light to Black
    // Statusbar gets white text again, Toolbar not ????
    // Hiding/showing ToolBar fixes this
    // so as workaround switch to 'none' and back to 'toolbar'
    // there's a short flicker TODO
    Timer {
        id: styleHintsTimer
        repeat: false
        interval: 200
        onTriggered: {
            Application.styleHints.colorScheme = appWindow.myStatusbarCholorScheme
            if(appWindow.headerType === "toolbar") {
                appWindow.headerType = "none"
                appWindow.headerType = "toolbar"
            }
        }
    } // styleHintsTimer

    // SETS SIZE AND ORIENTATION in AppState (QML SINGLETON)
    function initSizeAndOrientation() {
        console.log("appWindow initSizeAndOrientation")
        AppState.appWidth = width
        AppState.appHeight = height
        AppState.appOrientation = Screen.orientation
    }
    // SETS NON SAFE AREAS in AppState (QML SINGLETON)
    // SafeArea values belong to ApplicationWindow
    function updateSafeArea() {
        console.log("appWindow updateSafeArea")
        let m = SafeArea.margins
        AppState.safeAreaTopOrigin = m.top
        AppState.safeAreaLeftOrigin = m.left
        AppState.safeAreaRightOrigin = m.right
        AppState.safeAreaBottomOrigin = m.bottom
        //
        console.log("safe TBLR",AppState.safeAreaTop,AppState.safeAreaBottom,AppState.safeAreaLeft,AppState.safeAreaRight)
        console.log("appWindow padding TBLR",appWindow.topPadding, appWindow.bottomPadding, appWindow.leftPadding, appWindow.rightPadding)

        // workaround Android ?
        // Sometimes SafeAreas are not initialized at start on Android < 15
        if(Qt.platform.os === "android"
                && AppState.safeAreaTopOrigin===0 && AppState.safeAreaLeftOrigin === 0
                && AppState.safeAreaRightOrigin === 0
                && AppState.safeAreaBottomOrigin === 0) {
            console.log("A N D R O I D    ALL   Z E R O")
            // tried to start a Timer and to get SafeArea.margins again
            // but all Areas remain  zero
            // so ATM only helps to rotate to Landscape and back to Portrait
            // will wait for 6.9.3 to get this fixed
            // otherwise TODO setting orientation from C++ to Landscape and then Portrait
        }
    }


    Component.onCompleted: {
        console.log("appWindow Component onCompleted, init size, orientation, SafeArea")
        // set initial values for size, orientation, SafeArea and colorScheme in AppState Singleton
        initSizeAndOrientation()
        // our default Material.primary color is Teal,
        // used as background for System StatusBar
        // Teal needs white textcolor, so ColorScheme Dark is set
        // see materialButton and myMaterialMenu to test other colors
        // Hint: in Qt 6.9.2 switching StyleHints doesn't work on Android
        // see https://bugreports.qt.io/browse/QTBUG-137248
        // Application.styleHints.colorScheme = appWindow.myStatusbarCholorScheme
        styleHintsTimer.start()
        updateSafeArea()
    } // onCompleted
} // appWindow

// TODOs:
// special coloring for Android NavigationBar in Portrait and Landscape
// Test on Android devices with NavigationBar vs Gestures
// Test TabBar in Footer
// Some more different Pages with ListView and more pushing on StackView
// SwipeView test added. looks good in Portrait, also in Landscape on iOS
//           Landscape on Android with NavigationBar:
//           see https://bugreports.qt.io/browse/QTBUG-139690
// Android Split Screen: from discussions at https://bugreports.qt.io/browse/QTBUG-135808:
//                       SafeAreas don't report correct values if Android Split Screen in 6.9.2

// Have FUN :) ... ekke
