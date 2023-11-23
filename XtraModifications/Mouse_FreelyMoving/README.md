# Parts principally used with freely-moving mice
<p align="justify"> Each part will have a file associated with it, and where possible, this will be in an editable format. It will also include the material typically used to print the part, and the contact details of the designer. Please acknowledge the designer appropriately if you use any of these parts.  </p>

## NP1_HeadstageHolder.f3d
### Function
<p align="justify"> The NP1_HeadstageHolder was designed to allow free-moving recordings with the [Neuropixels 1.0 version](https://github.com/Coen-Lab/chronic-neuropixels/tree/main/NP1) of the Apollo implant and probes. It prevents damage to the ZIF pads during recordings. In our first recordings with the NP1 implant, we folded the probe flex underneath the caps (within the implant) so that the ZIF connector of the probe permanently protruded from the top of the implant (Fig 1A). During recordings, the headstage was connected to the probe and sat unsupported above the implant/animal.
<br>
<br>
Whilst recordings were possible in this configuration, the force exerted by the animal movement on the ZIF connector introduced noise into the recordings. This force and tension on the ZIF connector later damaged the gold pads on the flex, result in frequent error #14, 'BIST_ERROR', for the Parallel Serial Bus probe tests, which indicates a poorly seated probe. 
<br>
<br>
The headstage can be attached to the NP1_HeadstageHolder with epoxy (permanent) or a wrap of parafilm (temporary). Prior to recordings, the arms of the NP1_HeadstageHolder are slid onto the ridges of the NP1_Payload (as with the NP1_PayloadHolder) (Fig 1B). The probe flex is lopped between the NP1_Payload and NP1_HeadstageHolder and attached to the ZIF connector at the base (Fig 1C). Importantly, for this to work the flex needs to be full length. </p>

![Figure_github](https://github.com/NathanaelONeill/Apollo_Implant_Modifications/assets/94172541/5feb5479-5040-4a93-9992-617a45e0eeae)

### Material
<p align="justify"> Selective laser sintering. Material: Nylon PA12. Printed by: www.sgd3d.co.uk. Weight (without the headstage) = 0.5 g </p>

### Contact
<p align="justify"> Design was by Nathanael O'Neill, a postdoc in the Lignani lab, UCL email: skgtnon@ucl.ac.uk </p>
<p align="justify">Freely moving recordings using NP1_HeadstageHolder were performed by Nathanael O'Neill and James Street </p>
<p align="justify">The dimensions of the headstage mount of the NP1_HeadstageHolder were from [Emily A. Aery Jones](https://github.com/emilyasterjones)'s excellent [protocol](https://github.com/emilyasterjones/chronic_NPX_mouse) </p>

<br>
<br>

Sofware used: <br>

<br>
<br>
[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
