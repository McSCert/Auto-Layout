# Auto Layout Tool

Modeling operations often perturb a model's layout. Layout readjustment is usually needed, and represents a tedious activity if performed manually. Although achieving a proper layout of a Simulink model is deemed very important, there does not exist a comprehensive commercial automatic layout tool for Simulink models.

The Auto Layout Tool resizes models' blocks based on number of inputs and outputs, and organizes the signal lines such that the number of crossings is minimized. Auto Layout Tool can leverage three different layout approaches:

1. "Graphviz", a third-party open source tool for drawing graphs
1. Matlab’s built-in "GraphPlot" layout capability
1. An in-house "DepthBased" method

*Approaches 1) and 3) can be utilized on any version of Matlab/Simulink, while approach 2) only works on R2015b+.*

<img src="imgs/Cover.png" width="650">

## User Guide
For installation and other information, please see the [User Guide](doc/AutoLayout_UserGuide.pdf).

## Related Publications

Vera Pantelic, Steven Postma, Mark Lawford, Alexandre Korobkine, Bennett Mackenzie, Jeff Ong, Marc Bender, ["A Toolset for Simulink: Improving Software Engineering Practices in Development with Simulink,"](https://ieeexplore.ieee.org/document/7323083/) In *Proceedings of 3rd International Conference on Model-Driven Engineering and Software Development (MODELSWARD 2015)*, SCITEPRESS, 2015, 50-61. DOI: https://doi.org/10.5220/0005236100500061 (Best Paper Award)

Vera Pantelic, Steven Postma, Mark Lawford, Monika Jaskolka, Bennett Mackenzie, Alexandre Korobkine, Marc Bender, Jeff Ong, Gordon Marks, Alan Wassyng, [“Software engineering practices and Simulink: bridging the gap,”](https://link.springer.com/article/10.1007/s10009-017-0450-9) *International Journal on Software Tools for Technology Transfer (STTT)*, 2017, 95–117. DOI: https://doi.org/10.1007/s10009-017-0450-9 

## Matlab Central

This tool is also available on the [Matlab Central File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/51228-auto-layout-tool).

[![View Auto Layout Tool on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/51228-auto-layout-tool)
