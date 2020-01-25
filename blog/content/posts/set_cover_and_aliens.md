+++
title = "Set Cover and Aliens"
author = "Sean Carpenter"
date = "2020-01-16"
description = "A close look at the classic set cover problem through a post-apocalyptic lens"
featured_image = "posts/2020/set_cover_and_aliens/alien_abduction.png"
+++
![Warning Aliens](/images/posts/2020/set_cover_and_aliens/sign.png)
The year is 3000. Aliens have invaded and enslaved nearly the entire human race. You however have somehow managed to stay safe and out of sight from your would-be alien overlords, and are safely hidden in a small house in a rural part of the country. However, supplies are beginning to wear thin, and before long you know you're going to need to retrieve 4 different items from the various abandoned buildings around you. You'll need:

a Car Battery

a Flashlight

a Box of Matches

and a First Aid Kit

You've been hiding out here for a long time, and as such are rather familiar with the area. You know exactly where to find these items, but traveling to the different buildings for supplies is going to be risky. While you are out in the open, you're at risk of being abducted by a roving UFO's tractor beam, vaporized, or worse! Analyzing a map of the area indicates that there are 4 buildings within equal distance of each other that combined have all of the resources you need.

1: Car Battery, Flashlight
2: Box of Matches
3. First Aid Kit, Car Battery
4: First Aid Kit, Box of Matches

Additionally, your current circumstances indicate that you only need one of each of these items. Retrieving more than one copy of each item is simply not going to increase your chances of survival. With that in mind, which of these buildings should you visit to get **ALL** the items you need in the **MINIMUM** amount of trips? At a glance, it should be easy to tell that we should visit **Location 1** and **Location 4** to get the supplies we need, and that the minimum number of trips that we'll need to make to get all of our supplies is **2**. However, what if we wanted to devise an algorithm to find 100 items from 20 different locations? Well we'd need to come up with an algorithm of course! As it turns out, hidden within this somewhat silly example is a deceptively hard problem known as [The Set Cover Problem](https://en.wikipedia.org/wiki/Set_cover_problem). Before we try and come up with an algorithm however, let's take a step back and see if we can turn this problem into something a bit more general.


## Abstracting The Problem

To start off with, we can think of our items and locations as a set of subsets `S = {S0, S1, S2...}`, and the union of all subsets in `S` as the universal set `U`. In mathematical notation:

`U = union(n, i=1, Si)`
where `n` is the number of subsets in `S`.

**e.g.** The universal set `U` of the set `S`, where `S = {{1, 2}, {4, 5}, {2, 3}}` equals `{1, 2, 3, 4, 5}`.

Next, we're going to use the variable `P` to denote the [power set](https://en.wikipedia.org/wiki/Power_set) of `S`, or `p(S)`. The power set is defined as the set of all subsets of a given set, including the empty set `\O` and `S` itself.

**e.g.** The power set `P` of `{1, 2}` is `{{\0}, {1}, {2}, {1, 2}}`

Lastly, let's use `O` to denote the optimal (or minimal) set cover solution to any given set of sets `S`.

**e.g.** The optimal set cover solution `O` of `S` where `S = {{1, 2}, {3, 4}, {2, 3}}` is `{{1, 2}, {3, 4}}`

## Devising A Solution

With these tools at our disposal, we can finally begin to approach this problem. To start, it should be clear that if the power set `p(S)` or `P`, contains all possible combinations of subsets in `S`, and our optimal solution `O` is a combination of subsets in `S`, then `O ∈ P`. Therefore, every possible set cover of `S` (be it optimal or suboptimal) can be found within `P` as well. As a result, finding `O` is as simple as iterating through all of the sets in `P` to find the set with the least amount of subsets `S`, where the union of all of the subsets in `S` is equal to the universe `U`.

    def optimal_set_cover(S)
        P = power_set(S)
        U = universe(S)
        O = S
        for each set PSi ∈ P
            KU = The union of all sets in PSi
            if KU = U
                if cardinality(PSi) < cardinality(O)
                    O = PSi
        return O

Alright! With some psuedocode to guide our path, let's see if we can actually implement a solution in Python.

## Implementation

For starters we're going to need to write a function to generate power sets. This here is a clever solution written by ________

{{< highlight python >}}
def power_set(s):
    cardinality = len(s)
    ps = []
    for a in range(1 << cardinality):
        ps.append([s[b] for b in range(cardinality) if (a & (1 <<  b))])
    return ps
{{< /highlight >}}

We're also going to need a function to generate the universe of a set of subsets.

{{< highlight python >}}
def generate_universe(sos):
    result = set()
    for s in sos:
        result = result.union(s)
    return result
{{< /highlight >}}

With these two pieces, we have all we need to finally implement our optimal set cover algorithm

{{< highlight python >}}
def set_cover(sos):
    universe = generate_universe(sos)
    power_sos = power_set(sos)
    min_sos = sos
    for s in power_sos:
        current_universe = generate_universe(s)
        if current_universe == universe and len(s) < len(min_sos):
            min_sos = s
    return min_sos
{{< /highlight >}}


Oh no! This solution is super slow and a good solution doesn't exist! What to we do?

## Suboptimal Solutions
{{< highlight python >}}
def greedy_set_cover(sos):
    universe = generate_universe(sos)
    sorted_sos = sorted(sos, key=lambda x: len(x.intersection(universe)))
    min_sos = []
    known_universe = set()
    while sorted_sos:
        s = sorted_sos.pop()
        if known_universe.union(s) != known_universe:
            known_universe = known_universe.union(s)
            min_sos.append(s)
        if universe == known_universe:
            break
        # Put the set with the largest number of elements not yet in Universe at the top.
        sorted_sos = sorted(sorted_sos, key=lambda x: len(x.intersection(universe)))[::-1]
    return min_sos
{{< /highlight >}}
