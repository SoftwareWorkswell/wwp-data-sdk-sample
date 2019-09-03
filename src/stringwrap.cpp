#include "stringwrap.h"

StringWrap::StringWrap(QObject *parent) : QObject(parent) {
}

StringWrap::StringWrap(const QString &x, QObject *parent) : QObject(parent), m_value(x) {
}

QString StringWrap::value() {
  return m_value;
}
