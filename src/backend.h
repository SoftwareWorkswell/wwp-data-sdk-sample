#ifndef BACKEND_H
#define BACKEND_H

#include <QQmlListProperty>
#include <QObject>
#include <QList>
#include <QDebug>
#include <QTimer>
#include <QImage>
#include <QDir>
#include <QTime>
#include <iomanip>
#include <memory>
#include <center.h>
#include "stringwrap.h"

extern std::shared_ptr<wtl::ThermalImage> image;

class Backend : public QObject {

    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<StringWrap> qml_names READ qml_names NOTIFY dataChanged)
    Q_PROPERTY(int m_photoPointer READ getPhotoPointer WRITE setPhotoPointer)

    bool m_Radiometric = false;
    //Names&Paths
    QDir *m_folder = nullptr;
    QList<StringWrap*> m_wrapNameList;
    QList<QString> m_urls;
    bool m_imageLoaded = false;

    //Licenses
    QString m_authMessage = "License not activated, plase enter serial number.";
    QString m_authKey = nullptr;
    wtl::AuthState m_state;

    //Sequences
    QTimer *m_seqTimer = nullptr;
    std::shared_ptr<wtl::ThermalSequence> m_Sequence;
    bool m_SequenceLoaded = false;
    int m_CurrentSequenceFrame = 0;
    //Current file pointer
    int m_photoPointer = -1;
public:
    Backend(QObject *parent = nullptr);
signals:
    //Images&Palettes
    void dataChanged();
    void photoChanged();
    void photoDeleted();
    void imageWithPaletteLoaded(QString paletteName);
    void sequenceLoaded();
    void rangeChanged(bool manual);
    void newSource();
    void sourceError();
    //Licenses
    void keyChanged();
    void messageChanged();
    void activated();
    void deactivated();

public slots:
    //Images
    bool isSourceLoaded();
    bool containsGPSData();
    void makeFileData(QList<QUrl> newContent);
    void makeFolderData(QString content);
    QQmlListProperty<StringWrap> qml_names();
    QString getImageName(int pos);
    void photoBack();
    void photoNext();
    void deletePhoto(int currentRow);
    void deleteAll();
    int getPhotoPointer();
    void setPhotoPointer(int newValue);
    // force emit of photochanged signal to refresh photo using provider
    void forcePhotoChanged();
    //Sequences
    bool isSequenceLoaded();
    void loadSequence();
    void playSequence();
    void pauseSequence();
    void updateSequence();
    void refreshSequenceFrame();
    void setSequenceFrame(int frameNumber);
    void nextSequenceFrame();
    void prevSequenceFrame();
    QString getCurrentSequenceTime();
    int getCurrentSequenceTimeMS();
    QString getTotalSequenceTime();

    //Image loading & setting plalettes
    void loadImage();
    void exportThermalImage(const QString & path); // save as radiometric
    void exportBasicImage(const QString & path); // save as basic jpeg
    void newPalette(QString newPalette);

    //Temperature scale
    float getTemperature(int x, int y); // for radiometric
    int getRawRadiometricValue(float x, float y); // for radiometric
    QStringList getTemperatureScale();
    void setManualRangeOn();
    void setManualRangeOff();
    // setters for ranges
    void setMinTemperature(float newVal);
    void setMaxTemperature(float newVal);

    void addAlarmAbove(float val, QColor color);
    void addAlarmBelow(float val, QColor color);
    void addAlarmInterval(float upperVal, float lowerVal, QColor color);
    void addAlarmInvInterval(float upperVal, float lowerVal, QColor color);
    //Source info
    QString getCaptureTime();
    QString getResolution();
    double getEmissivity();
    double getReflectedTemp();
    double getAtmTemp();
    double getExternOpticTemp();
    double getObjectDistance();
    double getHumidity();
    double getExternOpticTrans();

    int getSequenceFramerate();
    int getSequenceTotalFrames();
    int getSequenceDuration();

    double getMaxImageTemp();
    double getMinImageTemp();

    void setEmissivity(double newVal);
    void setReflectedTemp(double newVal);
    void setAtmTemp(double newVal);
    void setExternOpticTemp(double newVal);
    void setObjectDistance(double newVal);
    void setHumidity(double newVal);
    void setExternOpticTrans(double newVal);

    QString getCameraName();
    QString getCameraManufacturer();
    QString getCameraSerialNumber();
    QString getCameraArticleNumber();

    //GPS info
    QString getAltitude();
    QString getLongitude();
    QString getLatitude();
    char getAltitudeRef();
    char getLongitudeRef();
    char getLatitudeRef();

    //Authentification dialog
    QString getAuthMessage();
    void setAuthMessage(QString newValue);
    void setAuthKey(QString newKey);
    bool authentification();
    void activate();
    void deactivate();
};

#endif // BACKEND_H
