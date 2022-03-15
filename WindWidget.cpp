#include "QtWindWidget.h"
#include <math.h>
#include "MultiVehicleManager.h"
//Costructor class
WindWidgetPost::WindWidgetPost(){
    manager = new QNetworkAccessManager();
    apiKey = "xulKWPwqRfkOooVOkEV9aBcB0rw26FO4";
    //connect(manager,SIGNAL(finished(QNetworkReply*)), this, SLOT(receivePayload(QByteArray*)));
    connect(manager,SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));

};
void WindWidgetPost::replyFinished(QNetworkReply* reply){
    if (reply->error()) {
        qDebug() << reply->errorString();
        return;
    } else {
        reply->deleteLater();
        emit speedChanged();
        emit checkChanged();
    }
    //========================================Parsing Speed and Direcion from Json==============================================//
    replyAll = reply->readAll(); //Qbytearray
    QJsonDocument replyDoc = QJsonDocument::fromJson(replyAll);
    QJsonObject replyObj = replyDoc.object();
    QJsonArray windUObjArray = replyObj["wind_u-surface"].toArray();
    QJsonArray windVObjArray = replyObj["wind_v-surface"].toArray();

    speed =sqrt(pow(windUObjArray[0].toDouble(),2) + pow(windVObjArray[0].toDouble(),2));
    writeSpeed(speed);
    emit speedChanged();

    //========================================Parsing Direction from Json==============================================//
    direction = atan(windUObjArray[0].toDouble() / windVObjArray[0].toDouble())*(180.0/M_PI);
    writeDirection(direction);
    emit directionChanged();
};

bool WindWidgetPost::getCheck()  {
    return check;
};

double WindWidgetPost::getSpeed(){
    return speed;
};

double WindWidgetPost::getLon(){
    return lonitude;
};


double WindWidgetPost::getDirection(){
    return direction;
};

QString WindWidgetPost::getApiKey(){
    return apiKey;
};

bool WindWidgetPost::writeCheck(bool i){
    check = i;
    if (check == 1){
    }
    return check;
};

void WindWidgetPost::writeSpeed(double i){
    speed = i;
};

void WindWidgetPost::writeDirection(double i){
    direction = i;
};

QString WindWidgetPost::writeApiKey(QString i){
    apiKey = i;
    return apiKey;
};

double WindWidgetPost::getlatitude(){
    return latitude;
};

void WindWidgetPost::writeLat(double i){
    latitude = i;

};

void WindWidgetPost::writeLon(double i){
    lonitude = i;

};

void WindWidgetPost::sendRequest(){
    QNetworkRequest request;
    request.setHeader( QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonArray parameters;
    QJsonDocument doc;
    request.setUrl(QUrl("https://api.windy.com/api/point-forecast/v2"));
    jsonReq.insert("lat",latitude);
    jsonReq.insert("lon",lonitude);
    jsonReq.insert("model","gfs");
    parameters.push_back("wind");
    jsonReq.insert("parameters",parameters);
    jsonReq.insert("key",apiKey);
    doc.setObject(jsonReq);
    QByteArray postData = doc.toJson();
    manager->post(request, postData);
};



