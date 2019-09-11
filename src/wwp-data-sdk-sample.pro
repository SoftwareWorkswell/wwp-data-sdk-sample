QT += quick
CONFIG += c++17


# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
  backend.cpp \
        main.cpp \
  stringwrap.cpp \
  thermalprovider.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Link your wwp-data-sdk here
win32 {
  INCLUDEPATH += "E:\Martin\WWPDataSDK\wt-lib\WT-lib"
  INCLUDEPATH += "E:\Martin\WWPDataSDK\wt-lib\WT-lib\libs\headers"
  INCLUDEPATH += "E:\Martin\C++ Boost Library\boost_1_70_0"
  LIBS += -L"E:\Martin\WWPDataSDK\wt-lib\build-WT-lib-Desktop_Qt_5_12_4_MSVC2017_64bit-Release\release" -lwwp-data-sdk
  LIBS += -L"E:\Martin\WWPDataSDK\wt-lib\WT-lib\libs\win" -llibjpeg -llibboost_date_time-vc141-mt-x64-1_70 -llibboost_regex-vc141-mt-x64-1_70
}
macx {
  INCLUDEPATH += "/Users/Workswell/Matej/Repos/wwp-data-sdk/wt-lib/WT-Lib"
  INCLUDEPATH += "/Users/Workswell/Matej/Repos/wwp-data-sdk/wt-lib/WT-Lib/libs/headers"
  INCLUDEPATH += "/Users/Workswell/Matej/Dev/Boost_1_70_0"

  LIBS += -L"$$_PRO_FILE_PWD_" -lwwp-data-sdk
  LIBS += -L"/Users/Workswell/Matej/Repos/wwp-data-sdk/wt-lib/WT-Lib/libs/macOS/" -ljpeg -lexif
}

HEADERS += \
    backend.h \
    stringwrap.h \
    thermalprovider.h

DISTFILES +=
