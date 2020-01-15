+++
title = "Concurrency In Go"
description = "A brief and pragmatic introduction to concurrency in Go."
type = "post"
date = "2020-01-14"
featured_image = "posts/2020/concurrency_in_go/gopher.png"
+++
## Introduction
Go (or Golang) is a relatively new language developed at Google that's garnered a lot of attention in the last few years for its simplicity, speed, and powerful concurrency features. In a rather short amount of time, a slew of extremely popular and performant applications have been built using Go. To name a few:
- [Terraform](https://github.com/hashicorp/terraform): A configuration language and engine used to generate and manage cloud infrastructure.
- [Kubernetes](https://github.com/kubernetes/kubernetes): A distributed server framework used to manage multiple containerized applications (not to mention [Docker](https://en.wikipedia.org/wiki/Docker_%28software%29) as well).
- [Hugo](https://github.com/gohugoio/hugo): A static site generator that uses an advanced markdown syntax to generate HTML. This website was built using Hugo!

If you already know Go, but want to improve your understanding of how to use its concurrency features, then read on. If you do not know Go, I'd recommend you first start off with the [Tour of Go](https://tour.golang.org/welcome/1), an interactive introduction to the language, as this post will assume you already know the basics. This introduction will also assume you understand the basics of concurrency. If you do not have a good understanding of how concurrency works, I'd first recommend you read the concurrency section in [OSTEP](http://pages.cs.wisc.edu/~remzi/OSTEP/), an awesome free operating systems textbook.
With that out of the way, lets take a look at the built-in concurrency features that make Go an exceptional language.

## Goroutines

Just as it'd be impossible to talk about concurrency without talking about threads, it would be impossible to talk about Go's concurrency model without talking about goroutines. Goroutines can be thought of as extremely light weight threads. Running a goroutine is as simple as adding the keyword `go` before a function call.

{{< highlight go >}}
import "fmt"
import "time"

func main() {
    go doWork(0)
    go doWork(1)

    doWork(2)
}

func doWork(worker int) {
    time.Sleep(500 * time.Millisecond)
    fmt.Printf("Worker %d: Jobs Done! \n", worker)
}
{{< /highlight >}}
```
Worker 0: Jobs Done!
Worker 2: Jobs Done!
Worker 1: Jobs Done!
```

It's important to note that any goroutines still alive when the main thread terminates will be unable to exit gracefully. With this in mind, it should be easy to spot the race condition in the previous code snippet.

Additionally, we're using the `time.sleep()` function to simulate doing "work." In the real world, "work" could be fetching an image from a URL, writing a file to a disk, or anything that takes time really. From our perspective however, it doesn't really matter what it is we're doing, so `time.sleep()` serves our purpose perfectly.

## Channels
After goroutines, channels are easily the most useful concurrency feature that Go has to offer. Channels are typed, thread-safe queues that make passing values between goroutines extremely easy. Placing values into channels is accomplished by directing the data you wish to pass into or out of the channel using arrow notation. Put plainly,

`c <- 10` will place the value `10` into the channel `c`
`x = <-c` will assign x to the oldest value in the channel `c`

{{< highlight go >}}
import "fmt"
import "time"

func main() {
    c := make(chan string)

    go doWork(c, 1)
    go doWork(c, 2)

    x := <-c
    y := <-c

    fmt.Println(x)
    fmt.Println(y)
}

func doWork(c chan string, worker int) {
    time.Sleep(500 * time.Millisecond)
    c <- fmt.Sprintf("Worker %d: Jobs Done!", worker)
}
{{< /highlight >}}


```
Worker 1: Jobs Done!
Worker 2: Jobs Done!
```

Part of what makes channels so useful is the fact that retrieving a value from a channel is a **blocking** operation. This means that any attempt to retrieve a value from an empty channel will block until a value is placed into that channel by a different goroutine. While this feature makes channels an extremely powerful tool for coordinating between multiple goroutines, it can also lead to deadlocks if you're not careful. For example, trying to retrieve a value from a channel that never has anything placed into it is guaranteed to deadlock:

{{< highlight go >}}
func main() {
    c := make(chan string)
    x := <-c
}
{{< /highlight >}}
```
fatal error: all goroutines are asleep - deadlock!
```

Lastly, although channels have no maximum size by default, you can specify one by passing an additional argument to the make function. For example, the following channel can store a maximum of 10 values.
{{< highlight go >}}
c := make(chan string, 10)
{{< /highlight >}}

As one might expect, just as trying to retrieve a value from an empty channel will block a goroutine, so will trying to place a value into a full channel. Unsurprisingly, we can (and will!) be able to use this behaviour to our advantage.

## Waitgroups
Waitgroups are a handy tool from the sync library that allow us to model situations where we want a goroutine to block until some specified amount of work has been completed. At their core, waitgroups are just thread-safe counters with three important operations:

`wg.Add(n)` increments the waitgroup `wg` by n
`wg.Done()` decrements the waitgroup `wg` by 1
`wg.Wait()` blocks the current thread until the waitgroup counter equals 0

{{< highlight go >}}
import "fmt"
import "math/rand"
import "sync"
import "time"

func main() {
    var wg sync.WaitGroup

    for i := 0; i < 5; i++ {
        wg.Add(1)
        go doWork(&wg, i)
    }

    wg.Wait() // Blocks Here
    fmt.Println("All done!")
}

func doWork(wg *sync.WaitGroup, worker int) {
    r := rand.Intn(5)
    time.Sleep(time.Duration(r) * 100 * time.Millisecond)

    fmt.Printf("Worker %d: Jobs Done!\n", worker)

    wg.Done()
}
{{< /highlight >}}
```
Worker 1: Jobs Done!
Worker 0: Jobs Done!
Worker 4: Jobs Done!
Worker 2: Jobs Done!
Worker 3: Jobs Done!
```
As a precaution, it's very easy to write code that deadlocks when using waitgroups. A simple off by one error is all you'd need to force our previous example to deadlock.

## Select
Another handy tool in our toolbox is the select statement. At a glance, a select statement looks a lot like a switch statement, but its functionality couldn't be more different. Instead of evaluating conditionals, a select statement is a blocking call that listens to multiple channels and executes the code attached to the channel it first recieves a value from. If multiple channels are ready to be pulled from, then one is chosen at random. Notably, select statements only execute once, so we'll need to wrap our select statement in a loop if we want to continuously read from our channels.

The following example demonstrates an extremely common pattern often seen when using the select statement. In it we use two channels, one to pass messages between our main thread and our goroutines, and a second to signal to our main loop to quit listening for new messages.

{{< highlight go >}}
import "fmt"
import "time"

func main() {
    jobs := make(chan int)
    quit := make(chan bool)

    go createJobs(jobs, quit)

    stop := false
    for !stop {
        select { // Blocks here
        case job := <-jobs:
            fmt.Printf("Job %d Complete!\n", job)
        case <-quit:
            stop = true
        }
    }
    fmt.Println("All Done!")
}

func createJobs(jobs chan int, quit chan bool) {
    for i := 1; i <= 10; i++ {
        time.Sleep(300 * time.Millisecond)
        jobs <- i
    }

    quit <- true // Signal that we're done.
}
{{< /highlight >}}
```
Job 1 Complete!
Job 2 Complete!
Job 3 Complete!

All Done!
```
## Mutexes
While it may seem strange to mention mutexes near the end of a discussion on concurrency, the powerful functionality that the previously mentioned features provide us often allow us to avoid using mutexes altogether.  However, they are an important part of the language, and often times the right tool for the job, so this post would be significantly lacking if they weren't mentioned at all.

Mutexes perform exactly like you'd expect, allowing you to lock and unlock around code sections to form critical sections. Below is a very simple example that uses mutexes to guarantee atomic updates to a single integer.

{{< highlight go >}}
import "fmt"
import "sync"

type safeNum struct {
    num   int
    mutex sync.Mutex
}

func main() {
    var wg sync.WaitGroup

    sf := safeNum{}
    sf.num = 0

    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go increment(&wg, &sf)
    }
    wg.Wait() // Blocks here
    fmt.Printf("Result: %d\n", sf.num)
}

func increment(wg *sync.WaitGroup, sf *safeNum) {
    sf.mutex.Lock()
    sf.num += 1 // CRITICAL SECTION
    sf.mutex.Unlock()

    wg.Done()
}
{{< /highlight >}}
```
Result: 100
```
## Semaphores (Bonus)
Although semaphores don't have their own implementation in Go, it's very easy to roll your own using buffered channels. Functionally, a buffered channel **is** a semaphore, except with the added benefit that we can also use it to pass values around. If we don't care about passing values around using our "semaphore", we can pass in an empty struct `struct{}` to avoid having to allocate any memory to what are essentially dummy values.

{{< highlight go >}}
func main() {
    semaphore := make(chan struct{}, 3)

    go func() {
        workerCount := 0
        for true {
            time.Sleep(100 * time.Millisecond)
            workerCount++
            go doWork(semaphore, workerCount)
        }
    }()
    time.Sleep(1000 * time.Millisecond)
}

func doWork(semaphore chan struct{}, worker int) {
    fmt.Println("Worker", worker, ": is waiting...")
    semaphore <- struct{}{} // Blocks here.

    fmt.Println("Worker", worker, ": has entered the critical section.")
    time.Sleep(600 * time.Millisecond)

    fmt.Println("Worker", worker, ": has left the critical section.")
    <-semaphore // Unblocks here.
}
{{< /highlight >}}
```
Worker 1 : is waiting...
Worker 1 : has entered the critical section.
Worker 2 : is waiting...
Worker 2 : has entered the critical section.
Worker 3 : is waiting...
Worker 3 : has entered the critical section.
Worker 4 : is waiting...
Worker 1 : has left the critical section.
Worker 4 : has entered the critical section.
Worker 5 : is waiting...
Worker 2 : has left the critical section.
Worker 5 : has entered the critical section.
Worker 6 : is waiting...
Worker 3 : has left the critical section.
Worker 6 : has entered the critical section.
```

## Conclusion

Well that's about it really! Hopefully you found this post useful. February's post will be all about exploring heuristic based algorithms used to generate sub-optimal [set cover](https://en.wikipedia.org/wiki/Set_cover_problem) solutions, so be sure to check back on the 1st if that sounds interesting to you.

If you have any suggestions, feedback or stumble across any bugs or typos, feel free to shoot me an email at  seancarpenter10@gmail.com

## Additional Resources

- Rob Pike - [Go Concurrency Patterns](https://talks.golang.org/2012/concurrency.slide#1)
- Rob Pike - [Concurrency Is Not Parallelism](https://vimeo.com/49718712)

All code used in the making of this post can be found [here](https://github.com/Seancarpenter/blog-content/tree/master/2020/concurrency_in_go).
