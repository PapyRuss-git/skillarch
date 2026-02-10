pragma Singleton
import QtQuick

QtObject {
    property bool overviewOpen: false

    // null = fermé, objet screen = ouvert sur cet écran
    property var quickSettingsScreen: null
    property bool quickSettingsOpen: quickSettingsScreen !== null

    // Workspace app icons (Super hold)
    property bool showWorkspaceIcons: false
    property var workspaceWindows: []

    // Brightness refresh signal (triggered by IPC from keyboard keys)
    property int brightnessRefreshCount: 0

    onOverviewOpenChanged: if (overviewOpen) quickSettingsScreen = null
    onQuickSettingsScreenChanged: if (quickSettingsScreen !== null) overviewOpen = false
}
