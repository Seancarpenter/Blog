+++
title = "Concurrency In Go"
description = "A brief and pragmatic introduction to concurrency in Go."
type = "post"
date = "2020-01-10"
featured_image = "posts/2020/concurrency_in_go/gopher.png"
+++

This article offers a sample of basic Markdown syntax that can be used in Hugo content files, also it shows whether basic HTML elements are decorated with CSS in a Hugo theme.
<!--more-->

## Headings

The following HTML `<h1>`—`<h6>` elements represent six levels of section headings. `<h1>` is the highest section level while `<h6>` is the lowest.

# H1
## H2
### H3
#### H4
##### H5
###### H6

## Paragraph

Xerum, quo qui aut unt expliquam qui dolut labo. Aque venitatiusda cum, voluptionse latur sitiae dolessi aut parist aut dollo enim qui voluptate ma dolestendit peritin re plis aut quas inctum laceat est volestemque commosa as cus endigna tectur, offic to cor sequas etum rerum idem sintibus eiur? Quianimin porecus evelectur, cum que nis nust voloribus ratem aut omnimi, sitatur? Quiatem. Nam, omnis sum am facea corem alique molestrunt et eos evelece arcillit ut aut eos eos nus, sin conecerem erum fuga. Ri oditatquam, ad quibus unda veliamenimin cusam et facea ipsamus es exerum sitate dolores editium rerore eost, temped molorro ratiae volorro te reribus dolorer sperchicium faceata tiustia prat.

Itatur? Quiatae cullecum rem ent aut odis in re eossequodi nonsequ idebis ne sapicia is sinveli squiatum, core et que aut hariosam ex eat.

## Blockquotes

The blockquote element represents content that is quoted from another source, optionally with a citation which must be within a `footer` or `cite` element, and optionally with in-line changes such as annotations and abbreviations.

#### Blockquote without attribution

> Tiam, ad mint andaepu dandae nostion secatur sequo quae.
> **Note** that you can use *Markdown syntax* within a blockquote.

#### Blockquote with attribution

> Don't communicate by sharing memory, share memory by communicating.</p>
> — <cite>Rob Pike[^1]</cite>


[^1]: The above quote is excerpted from Rob Pike's [talk](https://www.youtube.com/watch?v=PAAkCSZUG1c) during Gopherfest, November 18, 2015.

## Tables

Tables aren't part of the core Markdown spec, but Hugo supports supports them out-of-the-box.

   Name | Age
--------|------
    Bob | 27
  Alice | 23

#### Inline Markdown within tables

| Inline&nbsp;&nbsp;&nbsp;     | Markdown&nbsp;&nbsp;&nbsp;  | In&nbsp;&nbsp;&nbsp;                | Table      |
| ---------- | --------- | ----------------- | ---------- |
| *italics*  | **bold**  | ~~strikethrough~~&nbsp;&nbsp;&nbsp; | `code`     |

## Code Blocks

#### Code block with backticks

```
html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Example HTML5 Document</title>
</head>
<body>
  <p>Test</p>
</body>
</html>
```
#### Code block indented with four spaces

    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Example HTML5 Document</title>
    </head>
    <body>
      <p>Test</p>
    </body>
    </html>

#### Code block with Hugo's internal highlight shortcode
{{< highlight html >}}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Example HTML5 Document</title>
</head>
<body>
  <p>Test</p>
</body>
</html>
{{< /highlight >}}

## List Types

#### Ordered List

1. First item
2. Second item
3. Third item

#### Unordered List

* List item
* Another item
* And another item

#### Nested list

* Item
1. First Sub-item
2. Second Sub-item

## Other Elements — abbr, sub, sup, kbd, mark

<abbr title="Graphics Interchange Format">GIF</abbr> is a bitmap image format.

H<sub>2</sub>O

X<sup>n</sup> + Y<sup>n</sup> = Z<sup>n</sup>

Press <kbd><kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>Delete</kbd></kbd> to end the session.

Most <mark>salamanders</mark> are nocturnal, and hunt for insects, worms, and other small creatures.


## Introduction
Go (or Golang) is a relatively new language developed at Google that's garnered a lot of attention in the last few years for its simplicity, speed, and powerful concurrency features. In a rather short amount of time, a slew of extremely popular and performant applications have been built using Go. To name a few:
- [Terraform](https://github.com/hashicorp/terraform): A configuration language and engine used to generate and manage cloud infrastructure.
- [Kubernetes](https://github.com/hashicorp/kubernetes): A distributed server framework used to manage multiple containerized applications (not to mention [Docker](https://en.wikipedia.org/wiki/Docker_%28software%29) as well).
- [Hugo](https://github.com/gohugoio/hugo): A static site generator that uses a sort of advanced markdown syntax to generate HTML. This website was built using Hugo!

If you already know Go, but want to improve your understanding of how to use its concurrency features, then read on. If you do not know Go, I'd recommend you first start off with the [Tour of Go](https://tour.golang.org/welcome/1), an interactive introduction to the language, as this post will assume you already know the basics. This introduction will also assume you understand the basics of concurrency. If you do not have a good understanding of how concurrency works, I'd first recommend you read the concurrency section in [OSTEP](http://pages.cs.wisc.edu/~remzi/OSTEP/), an awesome free operating systems textbook.
With that out of the way, lets take a look at the built-in concurrency features that make Go an exceptional language.

## Goroutines

Just as it'd be impossible to talk about concurrency without talking about threads, it would impossible to talk about Go's concurrency model without talking about Goroutines. Goroutines can be thought of as extremely light weight threads. Running a goroutine is as simple as adding the keyword `go` before a function call.

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
```
Worker 0: Jobs Done!
Worker 2: Jobs Done!
Worker 1: Jobs Done!
```

It's important to note that any goroutines still alive when the main thread terminates will be unable to exit gracefully. With this in mind, it should be easy to spot the race condition in the previous code snippet.

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

```
Worker 1: Jobs Done!
Worker 2: Jobs Done!
```

## Waitgroup
{{< highlight go >}}
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
```
Job 1 Complete!
Job 2 Complete!
Job 3 Complete!

All Done!
```
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
```
Result: 100
```
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

## Additional Resources

- Rob Pike - [Go Concurrency Patterns](https://talks.golang.org/2012/concurrency.slide#1)
- Rob Pike - [Concurrency Is Not Parallelism](https://vimeo.com/49718712)

If you'd like to run the code exhibited in this post yourself, you can find it all [here](https://github.com/Seancarpenter/blog-content/tree/master/2020/concurrency_in_go).
