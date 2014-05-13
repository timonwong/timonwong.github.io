---
layout: post
title: "双轴倾角传感器计算坡度"
date: 2012-12-29 19:30
comments: true
categories: Sensor
---

令 $x$ 轴, $y$ 轴上的转角分别为 $\alpha, \beta$, 平面坡度为 $\theta$, 则:

$$
\begin{align}
  \theta = \arccos({
    \frac
      {1}
      {\sqrt{
        \tan^2{\alpha} + \tan^2{\beta} + 1
      }}
  })
\end{align}
$$

<!-- more -->

最近拿了个双轴倾角传感器玩玩，把公式和示例代码记下来备忘。

推导过程就省略了，下面是C语言描述的示例代码，其中 `calc_gradient_from_pitch_roll()` 函数的参数和返回值都是**弧度**。

``` c 坡度计算示例代码
#include <stdio.h>
#include <math.h>


#define MATH_PI     (3.14159f)

#define DEGREES_TO_RADIANS(angle)       ((angle) * ((MATH_PI) / 180.0f))
#define RADIANS_TO_DEGREES(radians)     ((radians) * (180.0f / (MATH_PI)))


float calc_gradient_from_pitch_roll(float pitch, float roll)
{
    float tan_pitch = tan(pitch);
    float tan_roll  = tan(roll);

    return acos(1.0f / sqrt(tan_pitch * tan_pitch + tan_roll * tan_roll + 1.0f));
}

// Test
int main(int argc, const char *argv[])
{
    for (;;) {
        float deg_pitch, deg_roll;
        printf("(in degress) pitch,roll = ");
        int ret = scanf("%f,%f", &deg_pitch, &deg_roll);

        if (ret == 2) {
            float pitch    = DEGREES_TO_RADIANS(deg_pitch);
            float roll     = DEGREES_TO_RADIANS(deg_roll);
            float gradient = calc_gradient_from_pitch_roll(pitch, roll);

            printf("(in degress) gradient = %f\n", RADIANS_TO_DEGREES(gradient));
        } else if (ret == EOF) {
            break;
        } else {
            // Print error message and clear the input buffer
            printf("Illegal input\n");
            setbuf(stdin, NULL);
        }
    }

    return 0;
}
```
