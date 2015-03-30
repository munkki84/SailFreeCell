#include "dbhelper.h"

#include <QQmlEngine>
#include <QDir>
DBHelper::DBHelper(QObject *parent) :
    QObject(parent)
{

}

DBHelper::DBHelper(QQuickView *view) :
    QObject(0)
{
    mainview = view;
    worker = new Worker;
    worker->moveToThread(&workerThread);
    connect(&workerThread, SIGNAL(finished()), worker, SLOT(deleteLater()));
    connect(this, SIGNAL(operate(QString, QVariantList, bool)), worker, SLOT(queueQuery(QString, QVariantList, bool)));
    connect(worker, SIGNAL(resultReady(QString)), this, SLOT(handleResults(QString)));
    workerThread.start();
}

DBHelper::~DBHelper()
{
    workerThread.quit();
    workerThread.wait();
}


//
// Queue queries on worker thread
//
// void queueQuery(parameter, values, consume)
// parameter: QString, query to run (SELECT is not supported)
// values: QVariantList, list of values that are subtituted in query string
// consume: bool, does the thread consume all current queries in the queue or only insert new queries to queue
// emits: nothing, at moment result of the query is not implemented
//
void
Worker::queueQuery(const QString &parameter, const QVariantList &values, bool consume)
{
    DBQuery newQuery;
    newQuery.query = parameter;
    newQuery.values = values;
    queue.Produce(newQuery);

    if (consume)
    {
        DBQuery nextQuery;
        QSqlQuery query(db);

        db.transaction();
        while(queue.Consume(nextQuery))
        {

            query.prepare(nextQuery.query);
            if (query.isSelect())
            {
                break;
            }

            for (int i = 0; i < nextQuery.values.size(); i++)
            {
                query.addBindValue(nextQuery.values.at(i));
            }
            query.exec();
        }
        db.commit();
    }

    emit resultReady("");
}

//
// Open database on worker thread
//
// bool openDB(path)
// path: QString, full path to SQLITE database file
// returns: bool, was database successfully opened
//
bool
Worker::openDB(const QString &path)
{
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);
    return db.open();
}

//
// Open database on worker thread, function searches a sqlite database of given name
// on the offlinestorage path and tries to open connection
//
// bool openDatabase(name)
// name: QString, name of the database
// returns: bool, was database successfully opened
//
bool
DBHelper::openDatabase(const QString &name)
{
    QString path = mainview->engine()->offlineStoragePath().append("/Databases");
    QString dbPath;
    QDir dir(path);
    QFileInfoList list = dir.entryInfoList();
    bool endLoop = false;
    for(int i = 0; i < list.size() && !endLoop; i++)
    {
        QFileInfo file = list.at(i);
        if(file.fileName().endsWith(".ini"))
        {
            QFile ini(file.absoluteFilePath());
            if (!ini.open(QIODevice::ReadOnly | QIODevice::Text))
                continue;

            while(!ini.atEnd())
            {
                QString line = ini.readLine();
                if(line.contains(name))
                {
                    dbPath= file.absoluteFilePath().replace(".ini", ".sqlite");
                    endLoop = true;
                }
            }

            ini.close();
        }

    }
    if (dbPath.isNull() || dbPath.isEmpty())
    {
        return false;
    }
    return worker->openDB(dbPath);
}

//
// Query result, not implemented
//
void
DBHelper::handleResults(const QString &)
{

}
