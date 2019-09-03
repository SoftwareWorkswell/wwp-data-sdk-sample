#ifndef STRINGWRAP_H
#define STRINGWRAP_H

#include <QObject>

class StringWrap : public QObject {

    Q_OBJECT
    Q_PROPERTY(QString value READ value CONSTANT)
    QString m_value;

public:

    explicit StringWrap(QObject *parent = nullptr);
    StringWrap(const QString &x, QObject *parent = nullptr);
    QString value();

};

#endif // STRINGWRAP_H
