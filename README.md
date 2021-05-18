# BumblebeeDetector
An iOS app developed for the dissertation project at the University of Sheffield.

# Project abstract:
As the bumblebee populations are changing rapidly, scientists are using various methods to monitor these trends. One of the tools used is survey work. It requires participants to keep track of the species, location and time, should they spot a bee in the wild. This task can sometimes be difficult for the participants since classifying a bumblebee species requires a lot of background knowledge and experience.

This project undertakes an effort to develop a proof of concept iOS application that would extract the bumblebee from the video and select the key frames to be sent to a species classifier to make the identification process smooth and easy. Several detection models have been trained, and various frame extraction methods implemented. Additionally, in an effort to speed up the detection process, a linear interpolation algorithm has been tested.

The final version of the app uses a CoreML model for localisation, methods relying on edge detection and image similarity for frame selection, and a species classifier developed by another student for classification. The whole process is fast, and provided the input video is of good quality, it detects the bee accurately. The final implementation runs the detector at an average of 34.43FPS and achieves an accuracy of 86.5\% on the testing set.

Going forward, the ideas and methods explored in this project could be implemented in an app for one of the population monitoring projects to aid the survey work.

A video demonstrating the application can be found here: https://youtu.be/bCldpGpj-0A
