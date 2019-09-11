#include "backend.h"

std::shared_ptr<wtl::ThermalImage> image;

Backend::Backend(QObject *parent) : QObject(parent) {
    QObject::connect(this, &Backend::keyChanged, this, &Backend::authentification);
}

//Images&Palettes
bool Backend::isSourceLoaded() {
    if(!m_urls.isEmpty() && image)
        return image != nullptr;
    else
        return false;
}

bool Backend::containsGPSData()
{
    if(!image)
        return false;
    return image->getImageMetaData().getGPSInfo().isValid();
}

bool Backend::isSequenceLoaded() {
    if(!m_urls.isEmpty())
        return m_SequenceLoaded;
    else
        return false;
}
// adding file urls
void Backend::makeFileData(QList<QUrl> newContent) {

    //Frontend list updating
    for(int i = 0; i < newContent.size(); i++) {
        QUrl newUrl = newContent[i].path();

#ifdef _MSC_VER
        newUrl = newContent[i].path().remove(0,1);
#endif
        QString newString = newUrl.fileName();
        if(!newString.contains(".wseq") && ! newString.contains(".seq")  && !wtl::Center::isRadiometricImage(newUrl.path().toStdString()))
        {
            qDebug() << "not a radiometric image" << newUrl.path();
            emit sourceError();
            return;
        }
        m_urls.append(newUrl.toString());
        StringWrap * newElement = new StringWrap(newString);
        m_wrapNameList.append(newElement);
        emit dataChanged();
        if(i == 0)
            setPhotoPointer(m_urls.size() - 1);
    }
}
// adding folder urls
void Backend::makeFolderData(QString newContent) {

    //Path
    QString folderPath;
    for(int i = 7; i < newContent.size(); i++)
        folderPath.append(newContent[i]);
    folderPath.append('/');
#ifdef _MSC_VER
    folderPath.remove(0,1);
#endif
    m_folder = new QDir(folderPath);

    //Filters
    QStringList filters;
    filters << "*.jpg" << "*.jpeg";
    m_folder->setNameFilters(filters);

    //Content of directory
    QList<QString> newList = m_folder->entryList();

    //Names Updating
    for(int i = 0; i < newList.size(); i++) {
        QString newString = newList[i];
        QString newUrl = m_folder->filePath(newString);
        if(!wtl::Center::isRadiometricImage(newUrl.toStdString()))
        {
            emit sourceError();
            continue;
        }
        m_urls.append(newUrl);
        StringWrap *newElement = new StringWrap(newString);
        m_wrapNameList.append(newElement);
        emit dataChanged();
        if(i == 0) { setPhotoPointer(m_urls.size() - 1); loadImage(); }
    }
}

QQmlListProperty<StringWrap> Backend::qml_names() {
    return QQmlListProperty<StringWrap> (this, m_wrapNameList);
}

QString Backend::getImageName(int pos) {
    return QUrl(m_urls.at(pos)).fileName();
}

void Backend::photoBack() {
    if((0 < m_photoPointer) && (m_photoPointer <= m_urls.size())) {
        if(isSequenceLoaded()) {
            pauseSequence();
            m_Sequence = nullptr;
        }
        m_photoPointer--;
        if(m_urls[m_photoPointer].contains(".wseq") || m_urls[m_photoPointer].contains(".seq") )
            loadSequence();
        else
            loadImage();
    }
}

void Backend::photoNext() {

    if((0 <= m_photoPointer) && (m_photoPointer < m_urls.size() - 1)) {
        if(isSequenceLoaded()) {
            pauseSequence();
        }
        m_photoPointer++;
        if(m_urls[m_photoPointer].contains(".wseq") || m_urls[m_photoPointer].contains(".seq") )
            loadSequence();
        else
            loadImage();
    }
}

void Backend::deletePhoto(int currentRow) {

    if(isSequenceLoaded()) pauseSequence();

    if(m_photoPointer >= currentRow) {
        m_photoPointer--;
        if(m_photoPointer == -1 && m_urls.size() != 1) m_photoPointer++;
    }

    if(m_photoPointer == -1) image = nullptr;

    m_wrapNameList.removeAt(currentRow);
    m_urls.removeAt(currentRow);

    emit dataChanged();
    emit photoChanged();
    emit photoDeleted();
}

void Backend::deleteAll() {
    m_photoPointer = -1;
    for(int i = m_urls.size() - 1; 0 <= i; i--)  {
        m_wrapNameList.removeAt(i);
        m_urls.removeAt(i);
    }
    image.reset();
    emit dataChanged();
    emit photoChanged();
    emit photoDeleted();
}

int Backend::getPhotoPointer() {
    return m_photoPointer;
}

void Backend::setPhotoPointer(int newValue) {
    m_photoPointer = newValue;
    if(m_urls[m_photoPointer].contains(".wseq") || m_urls[m_photoPointer].contains(".seq") )
        loadSequence();
    else
        loadImage();
}

void Backend::forcePhotoChanged()
{
    emit photoChanged();
}

//Sequences
void Backend::loadSequence() {

    if(m_urls[m_photoPointer].contains(".wseq"))
        m_Sequence = wtl::Center::loadSequenceRadiometric(m_urls[m_photoPointer].toStdString());
    else
       return;
    if(!m_Sequence)
    {
        emit sourceError();
        return;
    }
    m_SequenceLoaded = true;
    m_CurrentSequenceFrame = 0;
    image.reset();
    image = m_Sequence->thermalAt(m_CurrentSequenceFrame);
    if(!image)
    {
        emit sourceError();
        return;
    }
    emit sequenceLoaded();
    emit newSource();
    emit photoChanged();
}

void Backend::playSequence()
{
    if(!m_SequenceLoaded)
        return;
    qDebug() << "playy seq";
    if(m_seqTimer)
        delete m_seqTimer;
    m_seqTimer = new QTimer;
    m_seqTimer->setTimerType(Qt::PreciseTimer);
    connect(m_seqTimer, SIGNAL(timeout()), this, SLOT(updateSequence()));
    m_seqTimer->start(1000/m_Sequence->getSequenceMetaData().getFrameRate());
}

void Backend::pauseSequence()
{
    if(!m_SequenceLoaded)
        return;
    if(m_seqTimer)
        m_seqTimer->stop();
}

void Backend::updateSequence()
{
    if(m_CurrentSequenceFrame == m_Sequence->getSequenceMetaData().getNumberOfFrames()-1)
        m_CurrentSequenceFrame = 0;
    image.reset();
    image = m_Sequence->thermalAt(++m_CurrentSequenceFrame);
    if(image)
        emit photoChanged();
}

void Backend::refreshSequenceFrame()
{
    if(m_CurrentSequenceFrame == m_Sequence->getSequenceMetaData().getNumberOfFrames()-1)
        m_CurrentSequenceFrame = 0;
    image.reset();
    image = m_Sequence->thermalAt(m_CurrentSequenceFrame);
    if(image)
        emit photoChanged();
}


void Backend::setSequenceFrame(int frameNumber)
{
    qDebug() << "set seq frame: " << frameNumber;
    if(!m_SequenceLoaded || frameNumber < 0 || frameNumber >= m_Sequence->getSequenceMetaData().getNumberOfFrames())
        return;
    m_CurrentSequenceFrame = frameNumber;
    image.reset();
    image = m_Sequence->thermalAt(m_CurrentSequenceFrame);
    if(image)
        emit photoChanged();
}

void Backend::nextSequenceFrame()
{
    if(!m_SequenceLoaded)
        return;
    if(m_CurrentSequenceFrame ==  m_Sequence->getSequenceMetaData().getNumberOfFrames()-1 || (m_seqTimer && m_seqTimer->isActive()))
        return;
    image.reset();
    image = m_Sequence->thermalAt(++m_CurrentSequenceFrame);
    if(image)
        emit photoChanged();
}

void Backend::prevSequenceFrame()
{
    if(!m_SequenceLoaded)
        return;
    if(m_CurrentSequenceFrame == 0 || (m_seqTimer && m_seqTimer->isActive()))
        return;
    image.reset();
    image = m_Sequence->thermalAt(--m_CurrentSequenceFrame);
    if(image)
        emit photoChanged();
}

QString Backend::getCurrentSequenceTime()
{
    if(!m_SequenceLoaded)
        return "";
    int framerate = m_Sequence->getSequenceMetaData().getFrameRate();
    int currentTime = (int) (1000.0/framerate * m_CurrentSequenceFrame);
    qDebug() << framerate << currentTime << m_CurrentSequenceFrame;
    QTime time(0,0);
    time = time.addMSecs(currentTime);
    QString res = time.toString("mm:ss.zz");
    return res.remove(res.indexOf(".") + 3, res.length()-1);
}


int Backend::getCurrentSequenceTimeMS()
{
    if(!m_SequenceLoaded)
        return 0;
    int framerate = m_Sequence->getSequenceMetaData().getFrameRate();
    return (int) (1000.0/framerate * m_CurrentSequenceFrame);
}

QString Backend::getTotalSequenceTime()
{
    if(!m_SequenceLoaded)
        return "";
    int duration = m_Sequence->getSequenceMetaData().getDuration();
    QTime time(0,0);
    time = time.addMSecs(duration);
    QString res = time.toString("mm:ss.zz");
    return res.remove(res.indexOf(".") + 3, res.length()-1);
}


//Image loading & setting plalettes
void Backend::loadImage() {

    if(m_SequenceLoaded)
        m_SequenceLoaded = false;
    //Image
    if(wtl::Center::isRadiometricImage(m_urls[m_photoPointer].toStdString()))
    {
        qDebug() << "radio image";
        image.reset();
        image = wtl::Center::loadImageRadiometric(m_urls[m_photoPointer].toStdString());
    }
    else
    {
        emit sourceError();
        return;
    }

    emit photoChanged();
    emit newSource();
    emit imageWithPaletteLoaded(QString::fromStdString(image->getPalette().getName()));
}
void Backend::exportThermalImage(const QString & path)
{
    if(!image)
        return;
    qDebug() << "saving" << path << wtl::Center::saveImageRadiometric(std::static_pointer_cast<wtl::ImageRadiometric>(image), path.toStdString());
}

void Backend::exportBasicImage(const QString & path)
{
    if(!image)
        return;
    int imageSize = image->getImageMetaData().getWidth() * image->getImageMetaData().getHeight();
    uint8_t * imageData = new uint8_t [imageSize*3];
    image->getRGBArrayRepresentation(imageData, imageSize);
    QImage qimage((unsigned char*)imageData, image->getImageMetaData().getWidth(), image->getImageMetaData().getHeight(), image->getImageMetaData().getWidth() * 3, QImage::Format_RGB888);
    qimage.save(path);
    delete [] imageData;
}

void Backend::newPalette(QString newPalette)
{
    qDebug() << "Palette requested :" << newPalette;
    if(m_SequenceLoaded)
        m_Sequence->setPalette(newPalette.toStdString());
    image->setPalette(newPalette.toStdString());
}

//Temperature scale
float Backend::getTemperature(int x, int y) {
    return static_cast<wtl::ImageRadiometric*>(image.get())->getTemperature(x, y);
}

int Backend::getRawRadiometricValue(float x, float y) {
    return (int) static_cast<wtl::ImageRadiometric*>(image.get())->getRawRadiometricValue((int) x, (int) y);
}

QStringList Backend::getTemperatureScale() {

    float max;
    float min;

    max = static_cast<wtl::ImageRadiometric*>(image.get())->getMaxTemperature();
    min = static_cast<wtl::ImageRadiometric*>(image.get())->getMinTemperature();

    float step = (max - min) / 10;
    float last = max;
    std::string s[11];
    std::stringstream stream;
    QStringList result;
    stream << std::fixed << std::setprecision(1) << max;
    result.push_back(QString::fromStdString(stream.str()));
    stream.str("");
    for(int i = 1; i < 11; i++) {
        stream << std::fixed << std::setprecision(1) << last - step;
        result.push_back(QString::fromStdString(stream.str()));
        stream.str("");
        last = last - step;
    }
    return result;
}

void Backend::setManualRangeOn()
{

    if(m_SequenceLoaded)
    {
        m_Sequence->setManualRange(true);
        refreshSequenceFrame();
    }
    else if(image)
    {
        image->setManualRange(true);
    }
    emit rangeChanged(true);
}

void Backend::setManualRangeOff()
{
    if(m_SequenceLoaded)
    {
        m_Sequence->setManualRange(false);
        refreshSequenceFrame();
    }
    else if(image)
    {
        image->setManualRange(false);
        emit photoChanged();
    }
    emit rangeChanged(false);
}


void Backend::setMinTemperature(float newVal)
{
    if(m_SequenceLoaded)
    {
        if(m_Sequence->isRadiometricSequence())
             static_cast<wtl::SequenceRadiometric*>(m_Sequence.get())->setManualMin(newVal);
        refreshSequenceFrame();
    }
    else if(image)
    {
        if(image->isRadiometricImage())
            static_cast<wtl::ImageRadiometric*>(image.get())->setManualMin(newVal);
        emit photoChanged();
    }
}

void Backend::setMaxTemperature(float newVal)
{
    if(m_SequenceLoaded)
    {
        if(m_Sequence->isRadiometricSequence())
             static_cast<wtl::SequenceRadiometric*>(m_Sequence.get())->setManualMin(newVal);
        refreshSequenceFrame();
    }
    else if(image)
    {
        if(image->isRadiometricImage())
            static_cast<wtl::ImageRadiometric*>(image.get())->setManualMax(newVal);
        emit photoChanged();
    }
}

void Backend::addAlarmAbove(float val, QColor color)
{
    std::shared_ptr<wtl::AlarmStruct> alarm(new wtl::AlarmStruct);
    alarm->m_Type = wtl::AlarmType::Above;
    alarm->m_UpperValue = alarm->m_LowerValue = val;
    alarm->m_Color[0] = color.red();
    alarm->m_Color[1] = color.green();
    alarm->m_Color[2] = color.blue();
    if(m_SequenceLoaded)
    {
        if(m_Sequence->isRadiometricSequence())
        {
            wtl::SequenceRadiometric * radSeq = static_cast<wtl::SequenceRadiometric*>(m_Sequence.get());
            if(radSeq->getAlarms()->getAlarmCount() != 0)
                radSeq->getAlarms()->clear();
            radSeq->addAlarmToSequence(alarm);
            refreshSequenceFrame();
        }
    }
    else
    {
        if((!image) || !image->isRadiometricImage())
            return;
        wtl::ImageRadiometric * radImg = static_cast<wtl::ImageRadiometric*>(image.get());
        if(radImg->getAlarms()->getAlarmCount() !=0)
            radImg->getAlarms()->clear();
        radImg->addAlarmToImage(alarm);
        emit photoChanged();
    }
}

void Backend::addAlarmBelow(float val, QColor color)
{
    std::shared_ptr<wtl::AlarmStruct> alarm(new wtl::AlarmStruct);
    alarm->m_Type = wtl::AlarmType::Below;
    alarm->m_UpperValue = alarm->m_LowerValue = val;
    alarm->m_Color[0] = color.red();
    alarm->m_Color[1] = color.green();
    alarm->m_Color[2] = color.blue();
    if(m_SequenceLoaded)
    {
        if(m_Sequence->isRadiometricSequence())
        {
            wtl::SequenceRadiometric * radSeq = static_cast<wtl::SequenceRadiometric*>(m_Sequence.get());
            if(radSeq->getAlarms()->getAlarmCount() != 0)
                radSeq->getAlarms()->clear();
            radSeq->addAlarmToSequence(alarm);
            refreshSequenceFrame();
        }
    }
    else
    {
        if((!image) || !image->isRadiometricImage())
            return;
        wtl::ImageRadiometric * radImg = static_cast<wtl::ImageRadiometric*>(image.get());
        if(radImg->getAlarms()->getAlarmCount() != 0)
            radImg->getAlarms()->clear();
        radImg->addAlarmToImage(alarm);
        emit photoChanged();
    }
}

void Backend::addAlarmInterval(float upperVal, float lowerVal, QColor color)
{
    std::shared_ptr<wtl::AlarmStruct> alarm(new wtl::AlarmStruct);
    alarm->m_Type = wtl::AlarmType::Interval;
    alarm->m_UpperValue = upperVal;
    alarm->m_LowerValue = lowerVal;
    alarm->m_Color[0] = color.red();
    alarm->m_Color[1] = color.green();
    alarm->m_Color[2] = color.blue();
    if(m_SequenceLoaded)
    {
        if(m_Sequence->isRadiometricSequence())
        {
            wtl::SequenceRadiometric * radSeq = static_cast<wtl::SequenceRadiometric*>(m_Sequence.get());
            if(radSeq->getAlarms()->getAlarmCount() != 0)
                radSeq->getAlarms()->clear();
            radSeq->addAlarmToSequence(alarm);
            refreshSequenceFrame();
        }
    }
    else
    {
        if((!image) || !image->isRadiometricImage())
            return;
        wtl::ImageRadiometric * radImg = static_cast<wtl::ImageRadiometric*>(image.get());
        if(radImg->getAlarms()->getAlarmCount() != 0)
            radImg->getAlarms()->clear();
        radImg->addAlarmToImage(alarm);
        emit photoChanged();
    }
}

void Backend::addAlarmInvInterval(float upperVal, float lowerVal, QColor color)
{
    std::shared_ptr<wtl::AlarmStruct> alarm(new wtl::AlarmStruct);
    alarm->m_Type = wtl::AlarmType::InvertedInterval;
    alarm->m_UpperValue = upperVal;
    alarm->m_LowerValue = lowerVal;
    alarm->m_Color[0] = color.red();
    alarm->m_Color[1] = color.green();
    alarm->m_Color[2] = color.blue();
    if(m_SequenceLoaded)
    {
        if(m_Sequence->isRadiometricSequence())
        {
            wtl::SequenceRadiometric * radSeq = static_cast<wtl::SequenceRadiometric*>(m_Sequence.get());
            if(radSeq->getAlarms()->getAlarmCount() != 0)
                radSeq->getAlarms()->clear();
            radSeq->addAlarmToSequence(alarm);
            refreshSequenceFrame();
        }
    }
    else
    {
        if((!image) || !image->isRadiometricImage())
            return;
        wtl::ImageRadiometric * radImg = static_cast<wtl::ImageRadiometric*>(image.get());
        if(radImg->getAlarms()->getAlarmCount() != 0)
            radImg->getAlarms()->clear();
        radImg->addAlarmToImage(alarm);
        emit photoChanged();
    }
}

//Source info
QString Backend::getCaptureTime() {

    time_t t = image->getImageMetaData().getCaptureTime();
    struct tm *tm = localtime(&t);
    char date[20];
    strftime(date, sizeof(date), "%Y-%m-%d", tm);
    return date;
}

QString Backend::getResolution() {
    return QString::fromStdString(image->getImageMetaData().getResolution());
}

double Backend::getEmissivity() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getEmissivity();
    else
        return 0.0;
}

double Backend::getReflectedTemp() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getReflectedTemp();
    else
        return 0.0;
}

double Backend::getAtmTemp() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getAtmTemp();
    else
        return 0.0;
}

double Backend::getExternOpticTemp() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getExternOpticTemp();
    else
        return 0.0;
}

double Backend::getObjectDistance() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getObjectDistance();
    else
        return 0.0;
}

double Backend::getHumidity() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getHumidity();
    else
        return 0.0;
}

double Backend::getExternOpticTrans() {
    if(image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getExternOpticTrans();
    else
        return 0.0;
}

int Backend::getSequenceFramerate() {
    if(image->isRadiometricImage())
    if(!m_SequenceLoaded) return 0; return m_Sequence->getSequenceMetaData().getFrameRate();
}

int Backend::getSequenceTotalFrames() {
    if(!m_SequenceLoaded) return 0; return m_Sequence->getSequenceMetaData().getNumberOfFrames();
}

int Backend::getSequenceDuration() {
    if(!m_SequenceLoaded) return 0; return m_Sequence->getSequenceMetaData().getDuration();
}

double Backend::getMaxImageTemp()
{
    if(image && image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getMaxTemperature();
    else
        return 0.0;
}


double Backend::getMinImageTemp()
{
    if(image && image->isRadiometricImage())
        return static_cast<wtl::ImageRadiometric*>(image.get())->getMinTemperature();
    else
        return 0.0;
}


void Backend::setEmissivity(double newVal) {
    if(m_SequenceLoaded && m_Sequence->isRadiometricSequence())
        static_cast<wtl::SequenceRadiometric*>(m_Sequence.get())->setEmissivity(newVal);
    else if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setEmissivity(newVal);
    emit photoChanged();
}

void Backend::setReflectedTemp(double newVal) {
    if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setReflectedTemp(newVal);
    emit photoChanged();
}

void Backend::setAtmTemp(double newVal) {
    if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setAtmTemp(newVal);
    emit photoChanged();
}

void Backend::setExternOpticTemp(double newVal) {
    if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setExternOpticTrans(newVal);
    emit photoChanged();
}

void Backend::setObjectDistance(double newVal) {
    if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setObjectDistance(newVal);
    emit photoChanged();
}

void Backend::setHumidity(double newVal) {
    if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setHumidity(newVal);
    emit photoChanged();
}

void Backend::setExternOpticTrans(double newVal) {
    if(image->isRadiometricImage())
        static_cast<wtl::ImageRadiometric*>(image.get())->setExternOpticTrans(newVal);
    emit photoChanged();
}

QString Backend::getCameraName() {
    return QString::fromStdString(image->getImageMetaData().getCameraName());
}

QString Backend::getCameraManufacturer() {
    return QString::fromStdString(image->getImageMetaData().getCameraManufacturer());
}

QString Backend::getCameraSerialNumber() {
    return QString::fromStdString(image->getImageMetaData().getCameraSerialNumber());
}

QString Backend::getCameraArticleNumber() {
    return QString::fromStdString(image->getImageMetaData().getCameraArtn());
}


QString Backend::getAltitude() {
    std::stringstream stream;
    stream << std::fixed << std::setprecision(3) << image->getImageMetaData().getGPSInfo().getAltitude();
    return QString::fromStdString(stream.str());
}

QString Backend::getLongitude() {
    std::stringstream stream;
    stream << std::fixed << std::setprecision(3) << image->getImageMetaData().getGPSInfo().getLongitude();
    return QString::fromStdString(stream.str());
}

QString Backend::getLatitude() {
    std::stringstream stream;
    stream << std::fixed << std::setprecision(3) << image->getImageMetaData().getGPSInfo().getLatitude();
    return QString::fromStdString(stream.str());
}

char Backend::getAltitudeRef() {
    return image->getImageMetaData().getGPSInfo().getAltitudeRef();
}

char Backend::getLongitudeRef() {
    return image->getImageMetaData().getGPSInfo().getLongitudeRef();
}

char Backend::getLatitudeRef() {
    return image->getImageMetaData().getGPSInfo().getLatitudeRef();
}

//Authentification dialog
QString Backend::getAuthMessage() {
    return m_authMessage;
}

void Backend::setAuthMessage(QString newValue) {
    m_authMessage = newValue;
    emit messageChanged();
}

void Backend::setAuthKey(QString newKey) {
    m_authKey = newKey;
    emit keyChanged();
}

bool Backend::authentification() {

    qDebug() << "Authentificating";

    m_state = wtl::Center::authentificate();

    //if(authKey == nullptr) return false;
    if(m_state == wtl::AuthState::NotActivated)  {
        qDebug("NotActivated");
        m_authMessage = "License not activated, plase enter serial number.";
        emit messageChanged();
        emit deactivated();
        return false;
    }
    if(m_state == wtl::AuthState::FullActivated) {
        qDebug("FullActivated");
        m_authMessage = "Full license was activated succesfully!";
        emit messageChanged();
        emit activated();
        return true;
    }
    if(m_state == wtl::AuthState::TrialActivated) {
        qDebug("TrialActivated");
        m_authMessage = "Trial license was activated succesfully!";
        emit messageChanged();
        emit activated();
        return true;
    }
    if(m_state == wtl::AuthState::TrialExpired) {
        qDebug("TrialExpired");
        m_authMessage = "Trial license expired.";
        emit messageChanged();
        emit deactivated();
        return false;
    }
    if(m_state == wtl::AuthState::WrongSN) {
        qDebug("WrongSN");
        m_authMessage = "Invalid serial number entered.";
        emit messageChanged();
        emit deactivated();
        return false;
    }
    if(m_state == wtl::AuthState::ComputerAlreadyUsed) {
        qDebug("ComputerAlreadyUsed");
        m_authMessage = "This device is already activated.";
        emit messageChanged();
        return false;
    }
    if(m_state == wtl::AuthState::AlreadyUsed) {
        qDebug("AlreadyUsed");
        m_authMessage = "Serial number already used.";
        emit messageChanged();
        return false;
    }

    m_authMessage = "Error occured!";
    return false;
}

void Backend::activate() {
    qDebug() << "Activating" << m_authKey;
    wtl::Center::activate(m_authKey.toStdString());
    this->authentification();
}

void Backend::deactivate() {
    qDebug() << "Deactivating" << m_authKey;
    if(!wtl::Center::deactivate())
        return;
    this->authentification();
    emit deactivated();
}

