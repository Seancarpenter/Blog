+++
author = "Sean Carpenter"
title = "Welcome!"
date = 2020-01-01
description = "Welcome to Opinionator, a blog about various computer science and software engineering topics."
featured_image = "feature/opinionator.png"
+++

Thanks for dropping by! There's nothing here yet, but there will be soon. If you'd like to see how this website was made, you can find the source code for this website [here](https://github.com/Seancarpenter/Blog). The first post will be on the introduction to concurrency to Go that I presented at Devfest DC this last summer. If you'd like a sneak peak, you can find it [here](https://github.com/Seancarpenter/A-Pragmatic-Introduction-To-Concurrency-In-Go). Till next time!

    package main

    // Basic goroutine usage.
    import (
        "fmt"
        "time"
    )

    func main() {
        go doWork(0)
        go doWork(1)

        doWork(2)
    }

    func doWork(worker int) {
        time.Sleep(500 * time.Millisecond)
        fmt.Printf("Worker %d: Jobs Done! \n", worker)
    }
