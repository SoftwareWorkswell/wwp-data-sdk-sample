#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "center.h"
#include "thermalprovider.h"
#include "backend.h"
#include "stringwrap.h"

int main(int argc, char *argv[]) {

    //Design stuff
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    //Necessaryties
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    //Context
    engine.rootContext()->setContextProperty("_backend", new Backend); //One context property at a time
    engine.addImageProvider(QLatin1String("_provider"), new ThermalProvider);

    //Regitering types
    qmlRegisterType<Backend>("Components", 1, 0, "Backend");
    qmlRegisterType<StringWrap>("Components", 1, 0, "StringWrap");


    engine.load(QUrl("qrc:/main.qml"));

    int res = app.exec();
    return res;
}
