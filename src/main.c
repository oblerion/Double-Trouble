#include <stdio.h>
#include "raylib.h"


int main(int narg,char** sarg)
{
    // Initialization
    //--------------------------------------------------------------------------------------
   // float fraq = GetMonitorWidth(0)/GetMonitorHeight(0);
    const int screenWidth = (720*4)/3; //GetMonitorWidth(0);
    const int screenHeight = 720;//GetMonitorHeight(0);
    InitWindow(screenWidth, screenHeight, "start");
    SetTargetFPS(60);   // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        BeginDrawing();

        EndDrawing();
    }
    CloseWindow();   // Close window and OpenGL
    return 0;
}
