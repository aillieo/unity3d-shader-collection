## 04_ModelAlphaBlend

在模型中使用AlphaBlend，三个半透明的shader，从左到右依次是绘制双面、带深度绘制、使用Fresnel效果。

![Long](GALLERY/04_ModelAlphaBlend/Long.gif)
***
## 03_RadarImage

基于shader在UGUI中绘制雷达图。在vert中修改Image的顶点，并根据位置在frag中计算片段透明度。使用脚本驱动雷达图动画。

![radar](GALLERY/03_RadarImage/radar.gif)
***
## 02_ShowVerts

借助几何着色器，在绘制时只显示顶点。

![show_verts.png](GALLERY/02_ShowVerts/show_verts.png)
***
## 01_FragWorldPos

在片段着色器中获取世界坐标，并将坐标作为颜色输出。后处理阶段根据深度纹理解算出来像素对应的世界坐标，可用于做边界检测、运动模糊等效果。

透视相机，直接使用世界坐标绘制物体。

![perspective_0.png](GALLERY/01_FragWorldPos/perspective_0.png)

透视相机，在后处理阶段计算世界坐标并显示出来。

![perspective_1.png](GALLERY/01_FragWorldPos/perspective_1.png)

![perspective_2.png](GALLERY/01_FragWorldPos/perspective_2.png)

正交相机，直接使用世界坐标绘制物体。

![orthographic_0.png](GALLERY/01_FragWorldPos/orthographic_0.png)

正交相机，在后处理阶段计算世界坐标并显示出来。

![orthographic_1.png](GALLERY/01_FragWorldPos/orthographic_1.png)

![orthographic_2.png](GALLERY/01_FragWorldPos/orthographic_2.png)

后处理阶段，借助深度纹理获取世界坐标时，使用了两种不同的计算方法，详见相关代码。
***
