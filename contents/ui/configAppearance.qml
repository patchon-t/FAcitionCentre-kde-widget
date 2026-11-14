/* Widget settings: right-click the panel icons > Configure Quick Settings… */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_themeMode: themeCombo.currentIndex
    property alias cfg_useSystemAccent: accentCheck.checked

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: themeCombo
            Kirigami.FormData.label: "Colour mode:"
            model: ["Follow Plasma colour scheme", "Dark", "Light"]
        }
        QQC2.CheckBox {
            id: accentCheck
            Kirigami.FormData.label: "Accent colour:"
            text: "Use the Plasma accent colour instead of Windows blue"
        }
    }
}
