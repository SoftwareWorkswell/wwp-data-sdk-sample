#ifndef THERMALPROVIDER_H
#define THERMALPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QPainter>
#include <QUrl>
#include <QDebug>
#include <center.h>
#include "backend.h"

class ThermalProvider : public QQuickImageProvider
{
    uint8_t colors[256][3];
public:
    ThermalProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // THERMALPROVIDER_H
