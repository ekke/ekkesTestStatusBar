// AppState.qml   (QML Singleton)

// (c) 2025 Ekkehard Gentz (ekke) - Independent - Rosenheim Germany
// Qt Champion 2016 | 2024
// @ekkescorner.bsky.social
// @ekkescorner (X - aka Twitter)
// @ekke (Qt Discord Server)
// LinkedIn: http://linkedin.com/in/ekkehard/
// GitHub: https://github.com/ekke
// Qt6 blog: https://ekkesapps.wordpress.com/

// requires Qt 6.9.2+
// 2025-08-31

pragma Singleton
import QtQuick

QtObject {
    id: appState
    // SafeArea Properties (from ApplicationWindow)
    property int safeAreaTopOrigin: 0
    property int safeAreaLeftOrigin: 0
    property int safeAreaRightOrigin: 0
    property int safeAreaBottomOrigin: 0

    // SIZE and ORIENTATION (from ApplicationWindow)
    property int appWidth: 0
    property int appHeight: 0
    property int appOrientation: 0

    // LANDSCAPE
    readonly property bool isLandscape: appOrientation === Qt.LandscapeOrientation || appOrientation === Qt.InvertedLandscapeOrientation
    onIsLandscapeChanged: {
        console.log("Orientation isLandscape? change detected. isLandscape? ",isLandscape)
    }
    readonly property bool isLandscapeInverted: appOrientation === Qt.InvertedLandscapeOrientation
    onIsLandscapeInvertedChanged: {
        console.log("Orientation isLandscapeInverted? change detected. isLandscapeInverted? ",isLandscapeInverted)
    }

    // ADJUST SAFE AREAS ?
    // TOP
    readonly property int safeAreaTop:  safeAreaTopOrigin
    // BOTTOM
    readonly property int safeAreaBottom:  safeAreaBottomOrigin

    // iOS: Landscape Right or Left - apple sets both symmetrical
    // https://bugreports.qt.io/browse/QTBUG-135808
    // https://stackoverflow.com/questions/46972733/avoid-symmetrical-safe-area-when-designing-with-iphone-x-in-mind

    // in ekkes business apps we need as much space as possible for app data
    // reducing to 24 on the side without notch on ios looks good
    readonly property int iosLandscapeRightLeftMinimum: 24
    readonly property bool avoidSymmetricalSafeAreas: Qt.platform.os === "ios"? true : false

    // RIGHT
    readonly property int safeAreaRight: (
        avoidSymmetricalSafeAreas && isLandscapeInverted
        && safeAreaLeftOrigin === safeAreaRightOrigin
        && safeAreaRightOrigin > 0)
        ? iosLandscapeRightLeftMinimum : safeAreaRightOrigin

    // LEFT
    readonly property int safeAreaLeft: (
        avoidSymmetricalSafeAreas && isLandscape && !isLandscapeInverted
        && safeAreaLeftOrigin === safeAreaRightOrigin
        && safeAreaLeftOrigin > 0)
        ? iosLandscapeRightLeftMinimum : safeAreaLeftOrigin

    // MAX SAFE WIDTH/HEIGHT
    readonly property int maxSafeWidth: appWidth - safeAreaLeft - safeAreaRight
    readonly property int maxSafeHeight: appHeight - safeAreaTop - safeAreaBottom

    Component.onCompleted: {
        console.log("QML Singleton AppState Component onCompleted")
    }
} // appState
