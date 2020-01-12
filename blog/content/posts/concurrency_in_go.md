+++
title = "Concurrency In Go"
description = "A brief and pragmatic introduction to concurrency in Go."
type = "post"
date = "2020-01-10"
featured_image = "feature/opinionator.png"
+++
## Introduction

Go (or Golang) is a relatively new language developed at Google that's garnered a lot of attention in the last few years for its simplicity, speed, and powerful concurrency features. In a rather short amount of time, a slew of extremely popular and performant applications have been built using Go. To name a few:

- [Terraform](https://github.com/hashicorp/terraform): A configuration language and engine used to generate and manage cloud infrastructure.
- [Kubernetes](https://github.com/hashicorp/kubernetes): A distributed server framework used to manage multiple containerized applications (not to mention [Docker](https://en.wikipedia.org/wiki/Docker_%28software%29) as well).
- [Hugo](https://github.com/gohugoio/hugo): A static site generator that uses a sort of advanced markdown syntax to generate HTML. This website was built using Hugo!

If you already know Go, but want to improve your understanding of how to use its concurrency features, then read on. If you do not know Go, I'd recommend you first start off with the [Tour of Go](https://tour.golang.org/welcome/1), an interactive introduction to the language, as this post will assume you already know the basics. This introduction will also assume you understand the basics of concurrency. If you do not have a good understanding of how concurrency works, I'd first recommend you read the concurrency section in [OSTEP](http://pages.cs.wisc.edu/~remzi/OSTEP/), an awesome free operating systems textbook.

All that aside, lets take a look at the built-in concurrency features that make Go an exceptional language.

## Goroutines
{{< highlight go >}}
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
## Channel
{{< highlight go >}}
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
## Waitgroup
{{< highlight go >}}
func main() {
    var wg sync.WaitGroup

    for i := 0; i < 10; i++ {
        wg.Add(1)
        go doWork(&wg, i)
    }

    wg.Wait() // Blocks Here
    fmt.Println("All done!")
}

func doWork(wg *sync.WaitGroup, worker int) {
    r := rand.Intn(10)
    time.Sleep(time.Duration(r) * 100 * time.Millisecond)

    fmt.Printf("Worker %d: Jobs Done!\n", worker)

    wg.Done()
}
{{< /highlight >}}
## Select
{{< highlight go >}}
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
## Mutex
{{< highlight go >}}
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
## Semaphore (Bonus)
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
