#include <QNetworkReply>
#include <QNetworkRequest>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QString>

#ifndef QTWINDWIDGET_H
#define QTWINDWIDGET_H

#endif // QTWINDWIDGET_H

class WindWidgetPost : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool check READ getCheck WRITE writeCheck NOTIFY checkChanged)
    Q_PROPERTY(double direction READ getDirection WRITE writeDirection NOTIFY directionChanged)
    Q_PROPERTY(double speed READ getSpeed WRITE writeSpeed NOTIFY speedChanged)
    Q_PROPERTY(QString apiKey READ getApiKey WRITE writeApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(double latitude READ getlatitude WRITE writeLat NOTIFY latitudehanged)
    Q_PROPERTY(double lonitude READ getLon WRITE writeLon NOTIFY lonitudehanged)


public:

    explicit WindWidgetPost();
    QString json;
    QString apiKey;
    bool getCheck();
    double getSpeed();
    double getlatC();
    QString getApiKey();
    double getlatitude();
    double getLon();

signals:
    void checkChanged();
    void speedChanged();
    void directionChanged();
    void apiKeyChanged();
    void latitudehanged();
    void lonitudehanged();


public slots:
    void sendRequest();
    bool writeCheck(bool);
    void replyFinished(QNetworkReply *reply);
    void writeLat(double i);
    void writeLon(double i);
    double getDirection();
    QString writeApiKey(QString i);


private:
    void writeSpeed(double i);
    void writeDirection(double i);

    bool check;
    double latitude;
    double lonitude;

    double direction;
    double speed ;
    QNetworkAccessManager *manager;
    QJsonObject jsonReq;
    QByteArray replyAll;
};

