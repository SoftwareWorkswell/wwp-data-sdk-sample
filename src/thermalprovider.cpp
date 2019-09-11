#include "thermalprovider.h"

ThermalProvider::ThermalProvider() : QQuickImageProvider(QQuickImageProvider::Image) {}

void myImageCleanupHandler(void *info);
void paintCrosses(QImage & qimage);

QImage ThermalProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    if(id.contains("default_image")) return QImage(":/images/default.png");
    else if(id.contains("image")) {
        if(image == nullptr) return QImage(":/images/default.png");
        if(!image) {
            qDebug() << "Null image";
            return QImage(":/images/default.png");
        }
        int imageSize = image->getImageMetaData().getWidth() * image->getImageMetaData().getHeight();
        uint8_t * imageData = new uint8_t [imageSize*3];
        image->getRGBArrayRepresentationWithOverlay(imageData, imageSize);
        QImage qimage((unsigned char*)imageData, image->getImageMetaData().getWidth(), image->getImageMetaData().getHeight(), image->getImageMetaData().getWidth() * 3, QImage::Format_RGB888, myImageCleanupHandler, imageData);
        if(id.contains("painted")) // paint mix/max cross
        {
           paintCrosses(qimage);
        }
        return qimage;
    } else if(id.contains("custom_palette")) {
        image->getPalette().getPaletteRGBColors(colors);
        QImage palette(3, 256, QImage::Format_RGB32);
        QRgb q_colors;
        for(int i = 0; i< 256; i++) {
            q_colors = qRgb(colors[i][0], colors[i][1], colors[i][2]);
            palette.setPixel(0, 255 - i, q_colors);
            palette.setPixel(1, 255 - i, q_colors);
            palette.setPixel(2, 255 - i, q_colors);
        }

        return palette;
    } else if(id.contains("default_palette")) {
        QImage palette(256, 3, QImage::Format_RGB32);
        QRgb q_colors;
        for(int i = 0; i < 256; i++) {
            q_colors = qRgb(255,0,0);
            palette.setPixel(i, 0, q_colors);
        }
        for(int i = 0; i < 256; i++) {
            q_colors = qRgb(0,128,0);
            palette.setPixel(i, 1, q_colors);
        }
        for(int i = 0; i < 256; i++) {
            q_colors = qRgb(0,0,255);
            palette.setPixel(i, 2, q_colors);
        }
        return palette;
    }
    qDebug("No id recognized");
    return QImage(":/images/default.png");
}

void myImageCleanupHandler(void *info)
{
    delete [] (uint8_t*)(info);
}

void paintCrosses(QImage & qimage)
{
    int innerRectWidth = 2;
    int innerRectHeight = 16;
    int outerRectWidth = 4;
    int outerRectHeight = 18;
    int innerRectX = 7;
    int outerRectX = 1;
    int outerRectY = 8;
    QPainter paint;
    paint.begin(&qimage);
    std::pair<int, int> maxCoords = image->getMaxPos();
    int drawx = maxCoords.first;
    int drawy = maxCoords.second;
    QRect rectV(drawx-innerRectX, drawy, innerRectHeight, innerRectWidth);
    QRect rectH(drawx, drawy-innerRectX, innerRectWidth, innerRectHeight);
    QRect rectVB(drawx-outerRectY, drawy-outerRectX, outerRectHeight, outerRectWidth);
    QRect rectHB(drawx-outerRectX, drawy-outerRectY, outerRectWidth, outerRectHeight);
    paint.fillRect(rectVB, QBrush(Qt::black, Qt::SolidPattern));
    paint.fillRect(rectHB, QBrush(Qt::black, Qt::SolidPattern));
    paint.fillRect(rectV, QBrush(Qt::red, Qt::SolidPattern));
    paint.fillRect(rectH, QBrush(Qt::red, Qt::SolidPattern));
    std::pair<int, int> minCoords = image->getMinPos();
    drawx = minCoords.first;
    drawy = minCoords.second;
    rectV = QRect(drawx-innerRectX, drawy, innerRectHeight, innerRectWidth);
    rectH = QRect(drawx, drawy-innerRectX, innerRectWidth, innerRectHeight);
    rectVB = QRect(drawx-outerRectY, drawy-outerRectX, outerRectHeight, outerRectWidth);
    rectHB = QRect(drawx-outerRectX, drawy-outerRectY, outerRectWidth, outerRectHeight);
    paint.fillRect(rectVB, QBrush(Qt::black, Qt::SolidPattern));
    paint.fillRect(rectHB, QBrush(Qt::black, Qt::SolidPattern));
    paint.fillRect(rectV, QBrush(Qt::blue, Qt::SolidPattern));
    paint.fillRect(rectH, QBrush(Qt::blue, Qt::SolidPattern));
}
