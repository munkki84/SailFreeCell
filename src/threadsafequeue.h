/*
  Code from `Writing a Generalized Concurrent Queue`,
    By Herb Sutter, October 29, 2008

    http://www.drdobbs.com/cpp/211601363

*/

#ifndef THREADSAFEQUEUE_H
#define THREADSAFEQUEUE_H

#include <QtCore/QThread>
#include <QtCore/QAtomicInt>
#include <QtCore/QAtomicPointer>

/* pretty conservative estimate */
#define CACHE_LINE_SIZE 64
#define nullptr 0

template <typename T>
struct ThreadSafeQueue {
private:
    struct Node {
        Node( T* val ) : value(val), next(nullptr) { }
        T* value;
        QAtomicPointer<Node> next;
        char pad[CACHE_LINE_SIZE - sizeof(T*)- sizeof(QAtomicPointer<Node>)];
    };

    char pad0[CACHE_LINE_SIZE];

    // for one consumer at a time
    QAtomicPointer<Node> first;

    char pad1[CACHE_LINE_SIZE - sizeof(Node*)];

    // shared among consumers
    QAtomicInt consumerLock;

    char pad2[CACHE_LINE_SIZE - sizeof(QAtomicInt)];

    // for one producer at a time
    QAtomicPointer<Node> last;

    char pad3[CACHE_LINE_SIZE - sizeof(Node*)];

    // shared among producers
    QAtomicInt producerLock;

    char pad4[CACHE_LINE_SIZE - sizeof(QAtomicInt)];

public:
    ThreadSafeQueue()
        : producerLock(0)
        , consumerLock(0)
    {
        first = last = new Node( nullptr );
    }

    ~ThreadSafeQueue() {
        /* have to assume there are no others producing or consuming ! */
        while( first.load() ) {      // release the list
            Node* tmp = first.load();
            first = tmp->next;
            delete tmp->value;       // no-op if null
            delete tmp;
        }
    }

    void Produce( const T& t ) {
        Node* tmp = new Node( new T(t) );
        while( !producerLock.testAndSetOrdered(0,1) ) {
            // acquire exclusivity
            QThread::yieldCurrentThread();
        }
        last.load()->next.fetchAndStoreOrdered(tmp);         // publish to consumers
        last.fetchAndStoreOrdered(tmp);             // swing last forward
        producerLock.fetchAndStoreOrdered(0);       // release exclusivity
    }

    bool Consume(T& result ) {

        while( !consumerLock.testAndSetOrdered(0,1) ) {
            // acquire exclusivity
            QThread::yieldCurrentThread();
        }
        Node* theFirst = first.load();
        Node* theNext = theFirst->next.load();
        if( theNext != nullptr ) {   // if queue is nonempty
            T* val = theNext->value;    // take it out
            theNext->value = nullptr;  // of the Node
            first.fetchAndStoreOrdered(theNext);          // swing first forward
            consumerLock.fetchAndStoreOrdered(0);             // release exclusivity
            result = *val;    // now copy it back
            delete val;       // clean up the value
            delete theFirst;      // and the old dummy
            return true;      // and report success
        }
        consumerLock.fetchAndStoreOrdered(0);   // release exclusivity
        return false;                  // report queue was empty
    }
};

#undef nullptr  //dont want to affect other code with our crappy nullptr
#endif // THREADSAFEQUEUE_H
