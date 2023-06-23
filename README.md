# MIPS 32-bit Assembly Image Processing Application
This application is implemented in MIPS 32-bit assembly language using the MARS environment. It allows users to process and manipulate 24-bit Bitmap-encoded images. The application supports reading and writing images in this format and provides visual representation using the Bitmap Display tool available in MARS version 4.5. Users can also apply various image effects such as blurring, edge extraction, and threshold-based binarization, with customizable mask parameters.

This project was developed as part of the coursework for the Organização e Arquitetura de Computadores (Computer Organization and Architecture) course at the University of Brasília (UnB).
## Features
The MIPS assembly application offers the following features:
1. **Image Input and Output:** Users can provide input images in the Bitmap format and save processed images as output files.
2. **Bitmap Display:** The application utilizes the Bitmap Display tool to present the images in a graphical format.
3. **Image Processing Effects:**
- *Blurring:* Applies a blurring effect to the input image using a customizable mask.
- *Edge Extraction:* Extracts the edges from the input image using a customizable mask.
- *Threshold-based Binarization:* Converts the input image to a binary image by applying a threshold value provided by the user.
## Usage
To use the MIPS assembly image processing application, follow these steps:
1. Launch the MARS environment (version 4.5 or above).
2. Load the application's MIPS assembly source code into MARS.
3. Assemble and run the code.
4. The application will prompt you to provide an input image file in Bitmap format.
5. After loading the input image, the application will display the image using the Bitmap Display tool.
6. The application will present a menu with options to choose different image processing effects (blur, edge extraction, binarization).
7. Select the desired effect and provide any necessary parameters (e.g., blur, threshold value) as prompted by the application.
8. The processed image can be displayed using the Bitmap Display tool.
9. The application will prompt you to save the processed image as an output file.
10. Provide a filename for the output image, and the application will save the processed image in Bitmap format.
11. You can repeat the process with different effects or input images as needed.

## Implementation Details
The MIPS assembly code for this image processing application is designed to efficiently process and manipulate Bitmap-encoded images. It utilizes various MIPS instructions and programming techniques to achieve optimal performance.

The code includes comments to explain the purpose and functionality of each section and relevant instructions.

**Athors**:
Cristóvão Bartholo Gomes,
Douglas Maurício Bispo de Souza and
Estanislau Jacomé Dantas.
