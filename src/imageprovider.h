#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>

extern QString currentPhoto;

class ImageProvider : public QQuickImageProvider {

public:
    ImageProvider() : QQuickImageProvider(QQuickImageProvider::Image) { currentPhoto = nullptr; }

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
        if(currentPhoto != nullptr) {
            *size = QSize(currentPhoto->width(), currentPhoto->height());
            return *currentPhoto;
        }
        else {
            currentPhoto = new QImage(":/images/default.png");
            *size = QSize(currentPhoto->width(), currentPhoto->height());
            return *currentPhoto;
        }
    }
};

#endif // IMAGEPROVIDER_H
