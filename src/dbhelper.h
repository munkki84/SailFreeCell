//
// Database helper class for SQLITE localStorage database
// Queries are executed asyncronously in worker thread. Does not support SELECT queries
//

#ifndef DBHELPER_H
#define DBHELPER_H

#include <QObject>
#include <QThread>
#include <QQuickView>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlResult>
#include "threadsafequeue.h"


struct DBQuery
{
    QString query;
    QVariantList values;
};


class Worker : public QObject
{
    Q_OBJECT
    QThread workerThread;
    ThreadSafeQueue<DBQuery> queue;
    QSqlDatabase db;
public:
    bool openDB(const QString &path);

public slots:
    void queueQuery(const QString &parameter, const QVariantList &values, bool consume);

signals:
    void resultReady(const QString &result);
};

class DBHelper : public QObject
{
    Q_OBJECT
    QThread workerThread;
    Worker* worker;
    QQuickView* mainview;
public:
    explicit DBHelper(QObject* parent = 0);
    explicit DBHelper(QQuickView* view);
    ~DBHelper();
signals:
    void operate(const QString &, const QVariantList &, bool);
public slots:
    void handleResults(const QString &);
    bool openDatabase(const QString &name);
};

#endif // DBHELPER_H
