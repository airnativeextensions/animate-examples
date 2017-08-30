
Animate CC Example: 

Sample includes UI and functionality to support choosing an image from the CameraROLL and then reading the data from the image using OCR and converting it to a string.

Folder project structure:

ANE (air native extensions) - please use latest ANE's for OCR and Core
src (project folder)
- tessdata (OCR trained data files)
- includes (action script include files to separate code by function)
- OCR.fla (UI and core project code)
- OCR-app.xml (project export settings for iOS and android)
- Default-XXX.pngs (these images are used to scale the project to the correct resolution for the ios devices and also provide a launch image for the application while it is loading)
- image_sample.jpg (sample image to test OCR)
