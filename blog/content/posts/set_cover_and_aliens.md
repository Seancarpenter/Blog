+++
title = "Set Cover and Aliens"
author = "Sean Carpenter"
date = "2020-01-16"
description = "A close look at the classic set cover problem through a post-apocalyptic lens"
featured_image = "posts/2020/concurrency_in_go/gopher.png"
+++

## The Scenario
The year is 3000. Aliens have since invaded and enslaved nearly the entire human race. You however have somehow managed to stay safe and out of sight from your would-be alien overlords, and are safely hidden in a small house in a rural part of the country. However, supplies are beginning to wear thin, and before long you know you're going to need to retrieve 4 different items from the various abandonded buildings around you. You'll need:

a Car Battery

a Flashlight

a Box of Matches

and a First Aid Kit

You've been in hiding for a long time, and as such are rather familiar with the area. You know exactly where to find these items, but traveling to the different buildings for supplies is going to be risky. While you are out in the open, you're at risk of being abducted by a roving UFO's tractor beam, vaporized, or worse! Analyzing a map of the area indicates that there are 4 buildings within equal distance of each other that combined have all of the resources you need.

1: Car Battery, Flashlight
2: Box of Matches
3. First Aid Kit, Car Battery
4: First Aid Kit, Box of Matches

Additionally, your current circumstances indicate that you only need one of each of these items. Retriving more than one copy of each item is simply not going to increase your chances of survival. So, the question then becomes, which of these buildings should you visit to get **ALL** the items you need in the **MINIMUM** amount of trips. At a glance, it should be easy to tell that we should visit **Location 1** and **Location 4** to get the supplies we need, and that the minimum number of trips that we'll need to make to get all of our supplies is **2**. However, what if we needed 30 different items, and had over 25 different locations to choose from? As we'll soon find out, finding the absolute minimum set of locations we'll need to visit to get the items we need is an extremely hard problem. In fact it's so difficult, that there doesn't even exist an algorithm that can find a solution in polynomial time! Our simple search for resources is actually an NP-Hard problem!
