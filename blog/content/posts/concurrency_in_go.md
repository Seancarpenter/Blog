+++
title = "Concurrency In Go"
description = "A brief and pragmatic introduction to concurrency in Go."
type = "post"
date = "2020-02-01"
featured_image = "feature/opinionator.png"
+++

## Introduction

Go (or Golang) is a relatively new language developed at Google that's garnered a lot of attention in the last few years for its simplicity, speed, and powerful concurrency features. In a rather short amount of time, a slew of extremely popular and performant applications have been built using Go. To name a few:

- [Terraform](https://github.com/hashicorp/terraform): A configuration language and engine used to generate and manage cloud infrastructure.
- [Kubernetes](https://github.com/hashicorp/kubernetes): A distributed server framework used to manage multiple containerized applications (not to mention [Docker](https://en.wikipedia.org/wiki/Docker_%28software%29) as well).
- [Hugo](https://github.com/gohugoio/hugo): A static site generator that uses a sort of advanced markdown syntax to generate HTML. This website was built using Hugo!

If you already know Go, but want to improve your understanding of how to use its concurrency features, then read on. If you do not know Go, I'd recommend you first start off with the [Tour of Go](https://tour.golang.org/welcome/1), an interactive introduction to the language, as this post will assume you already know the basics. This introduction will also assume you understand the basics of concurrency. If you do not have a good understanding of how concurrency works, I'd first recommend you read the concurrency section in [OSTEP](http://pages.cs.wisc.edu/~remzi/OSTEP/), an awesome free operating systems textbook.

All that aside, lets take a look at the built-in concurrency features that make Go an exceptional language.

## Go Routines

    func main() {
        go doWork(0)
        go doWork(1)

        doWork(2)
    }

    func doWork(worker int) {
        time.Sleep(500 * time.Millisecond)
        fmt.Printf("Worker %d: Jobs Done! \n", worker)
    }
