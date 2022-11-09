
/* center radius (pixels) */
#define C_RADIUS screen.y / 7
/* center line thickness (pixels) */
#define C_LINE 0
/* outline color */
#define OUTLINE #333333
/* number of bars (use even values for best results) */
#define NBARS 360
/* width (in pixels) of each bar*/
#define BAR_WIDTH 18
/* outline color */
#define BAR_OUTLINE OUTLINE
/* outline width (in pixels, set to 0 to disable outline drawing) */
#define BAR_OUTLINE_WIDTH 0
/* Amplify magnitude of the results each bar displays */
#define AMPLIFY screen.x / 2
/* Bar color */
#define COLOR (#cc3333 * ((d / 80) + 1))
#define COLOR mix(#cc0000, #2233FF, clamp(d / 320, 0, 1))
/* Angle (in radians) for how much to rotate the visualizer */
#define ROTATE (PI / 2)
/* Whether to switch left/right audio buffers */
#define INVERT 1
/* Aliasing factors. Higher values mean more defined and jagged lines.
   Note: aliasing does not have a notable impact on performance, but requires
   `xroot` transparency to be enabled since it relies on alpha blending with
   the background. */
#define BAR_ALIAS_FACTOR 4.8
#define C_ALIAS_FACTOR 1.8
/* Offset (Y) of the visualization */
#define CENTER_OFFSET_Y 0
/* Offset (X) of the visualization */
#define CENTER_OFFSET_X 0

/* Gravity step, override from `smooth_parameters.glsl` */
#request setgravitystep 10

/* Smoothing factor, override from `smooth_parameters.glsl` */
#request setsmoothfactor 0.02
