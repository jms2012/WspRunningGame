#include <raylib.h>
#include <vector>
#include <iostream>
#include <cmath>

// 游戏常量
const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 600;
const char* GAME_TITLE = "WSP Running Game";

// 游戏状态枚举
enum GameState {
    RUNNING,
    PAUSED,
    UPGRADE_MENU
};

// 颜色定义
const Color WSP_BLUE = {50, 150, 255, 255};
const Color WSP_GREEN = {50, 200, 100, 255};
const Color WSP_YELLOW = {255, 200, 50, 255};
const Color WSP_RED = {255, 80, 80, 255};
const Color WSP_WHITE = {255, 255, 255, 255};
const Color WSP_BLACK = {0, 0, 0, 255};
const Color WSP_GRAY = {200, 200, 200, 255};

// 跑道类
class Track {
public:
    float radius;
    Vector2 center;
    Color color;
    
    Track(float r, Vector2 c, Color col) : radius(r), center(c), color(col) {}
    
    void Draw() {
        // 绘制跑道外圈
        DrawCircleLines(center.x, center.y, radius, color);
        // 绘制跑道内圈
        DrawCircleLines(center.x, center.y, radius - 20, color);
    }
};

// 小人类
class Runner {
public:
    float angle;
    float speed;
    float radius;
    Vector2 center;
    Vector2 idlePosition;
    Color color;
    int lapsCompleted;
    int currentLaps;
    float moneyPerLap;
    bool isRunning;
    bool isAutoRunning;
    
    Runner(float r, Vector2 c, Color col, Vector2 idlePos) : 
        angle(0.0f), speed(3.0f), radius(r), center(c), idlePosition(idlePos),
        color(col), lapsCompleted(0), currentLaps(0), moneyPerLap(1.0f), 
        isRunning(false), isAutoRunning(false) {}
    
    void StartRunning(int totalLaps) {
        isRunning = true;
        currentLaps = totalLaps;
    }
    
    void Update(float speedMultiplier) {
        if (isRunning) {
            angle += speed * speedMultiplier * 0.01f;
            if (angle >= 2 * PI) {
                angle = 0.0f;
                lapsCompleted++;
                currentLaps--;
                if (currentLaps <= 0) {
                    if (isAutoRunning) {
                        // 自动跑圈模式，跑完后重新开始
                        StartRunning(1);
                    } else {
                        isRunning = false; // 跑完指定圈数自动停止
                    }
                }
            }
        }
    }
    
    Vector2 GetPosition() {
        return Vector2{
            center.x + radius * cosf(angle),
            center.y + radius * sinf(angle)
        };
    }
    
    Vector2 GetDisplayPosition() {
        if (isRunning) {
            return GetPosition();
        } else {
            return idlePosition;
        }
    }
    
    bool IsClicked() {
        Vector2 pos = GetDisplayPosition();
        Vector2 mousePos = GetMousePosition();
        float distance = sqrtf(powf(mousePos.x - pos.x, 2) + powf(mousePos.y - pos.y, 2));
        return distance <= 15 && IsMouseButtonPressed(MOUSE_LEFT_BUTTON);
    }
    
    void ToggleRunning(int totalLaps) {
        if (isRunning) {
            isRunning = false;
        } else {
            StartRunning(totalLaps);
        }
    }
    
    void SetAutoRunning(bool autoRun) {
        isAutoRunning = autoRun;
        if (autoRun && !isRunning) {
            StartRunning(1);
        }
    }
    
    void Draw() {
        Vector2 pos = GetDisplayPosition();
        // 绘制小人主体
        DrawCircle(pos.x, pos.y, 15, color);
        // 绘制WSP文字
        DrawText("WSP", pos.x - 10, pos.y - 8, 12, WSP_WHITE);
        // 绘制状态指示
        if (isAutoRunning) {
            DrawCircle(pos.x, pos.y, 5, WSP_GREEN);
        } else if (!isRunning) {
            DrawCircle(pos.x, pos.y, 5, WSP_RED);
        }
    }
};

// 游戏管理类
class GameManager {
public:
    GameState state;
    std::vector<Runner> runners;
    Track track;
    float money;
    int runnerCount;
    float baseRunnerCost;
    float baseSpeedUpgradeCost;
    float baseMoneyUpgradeCost;
    float baseForemanUpgradeCost;
    float speedMultiplier;
    float moneyMultiplier;
    int foremanLevel;
    
    GameManager() : 
        state(RUNNING), 
        track(200, Vector2{SCREEN_WIDTH/2, SCREEN_HEIGHT/2}, WSP_GRAY),
        money(0.0f), runnerCount(1),
        baseRunnerCost(10.0f), baseSpeedUpgradeCost(5.0f), baseMoneyUpgradeCost(8.0f), baseForemanUpgradeCost(15.0f),
        speedMultiplier(1.0f), moneyMultiplier(1.0f), foremanLevel(0) {
        // 初始化第一个小人
        Vector2 idlePos = {50, 100};
        runners.emplace_back(200, Vector2{SCREEN_WIDTH/2, SCREEN_HEIGHT/2}, WSP_BLUE, idlePos);
    }
    
    void Update() {
        // 无论游戏状态如何，都更新小人（包括升级菜单打开时）
        for (auto& runner : runners) {
            // 检测小人是否被点击
            if (runner.IsClicked()) {
                runner.ToggleRunning(foremanLevel + 1); // 监工等级+1圈
            }
            
            float oldLaps = runner.lapsCompleted;
            runner.Update(speedMultiplier);
            if (runner.lapsCompleted > oldLaps) {
                money += runner.moneyPerLap * moneyMultiplier;
            }
        }
    }
    
    int GetAutoRunningCount() {
        int count = 0;
        for (const auto& runner : runners) {
            if (runner.isAutoRunning) {
                count++;
            }
        }
        return count;
    }
    
    void Draw() {
        // 绘制跑道
        track.Draw();
        
        // 绘制小人
        for (auto& runner : runners) {
            runner.Draw();
        }
        
        // 绘制货币显示
        DrawText(TextFormat("Money: $%.2f", money), 20, 20, 20, WSP_WHITE);
        
        // 绘制开始/暂停按钮
        if (state == RUNNING) {
            if (DrawButton(SCREEN_WIDTH - 120, 20, 100, 40, "Pause", WSP_YELLOW)) {
                state = PAUSED;
            }
        } else if (state == PAUSED) {
            if (DrawButton(SCREEN_WIDTH - 120, 20, 100, 40, "Resume", WSP_GREEN)) {
                state = RUNNING;
            }
        }
        
        // 绘制升级菜单按钮
        if (DrawButton(SCREEN_WIDTH - 120, 80, 100, 40, "Upgrade", WSP_BLUE)) {
            state = UPGRADE_MENU;
        }
        
        // 绘制升级菜单
        if (state == UPGRADE_MENU) {
            DrawUpgradeMenu();
        }
    }
    
    bool DrawButton(int x, int y, int width, int height, const char* text, Color color) {
        bool hovered = CheckCollisionPointRec(GetMousePosition(), Rectangle{float(x), float(y), float(width), float(height)});
        bool clicked = hovered && IsMouseButtonPressed(MOUSE_LEFT_BUTTON);
        
        // 绘制按钮
        DrawRectangle(x, y, width, height, hovered ? Fade(color, 0.8f) : color);
        DrawRectangleLines(x, y, width, height, WSP_WHITE);
        DrawText(text, x + (width - MeasureText(text, 16))/2, y + (height - 16)/2, 16, WSP_WHITE);
        
        return clicked;
    }
    
    void DrawUpgradeMenu() {
        // 绘制菜单背景
        DrawRectangle(100, 100, SCREEN_WIDTH - 200, SCREEN_HEIGHT - 200, Fade(WSP_BLACK, 0.8f));
        DrawRectangleLines(100, 100, SCREEN_WIDTH - 200, SCREEN_HEIGHT - 200, WSP_WHITE);
        
        // 绘制标题
        DrawText("Upgrade Menu", SCREEN_WIDTH/2 - MeasureText("Upgrade Menu", 24)/2, 120, 24, WSP_WHITE);
        
        // 购买更多小人
        float runnerCost = baseRunnerCost * pow(1.5f, runnerCount - 1);
        DrawText(TextFormat("Buy Runner: $%.2f", runnerCost), 150, 180, 20, WSP_WHITE);
        if (DrawButton(350, 170, 100, 40, "Buy", WSP_GREEN) && money >= runnerCost) {
            money -= runnerCost;
            runnerCount++;
            // 计算新小人的空闲位置（在屏幕左侧自动排列）
            Vector2 idlePos = {50, 100 + (runners.size() * 60)};
            // 安全地计算新颜色
            unsigned char r = (runners.back().color.r + 20) % 256;
            unsigned char g = (runners.back().color.g + 10) % 256;
            unsigned char b = (runners.back().color.b + 5) % 256;
            runners.emplace_back(200, Vector2{SCREEN_WIDTH/2, SCREEN_HEIGHT/2}, Color{r, g, b, 255}, idlePos);
        }
        
        // 升级速度倍率
        float speedUpgradeCost = baseSpeedUpgradeCost * pow(1.3f, runners.size());
        DrawText(TextFormat("Upgrade Speed: $%.2f (x%.1f)", speedUpgradeCost, speedMultiplier), 150, 250, 20, WSP_WHITE);
        if (DrawButton(350, 240, 100, 40, "Upgrade", WSP_BLUE) && money >= speedUpgradeCost) {
            money -= speedUpgradeCost;
            speedMultiplier *= 1.2f; // 每次升级增加20%速度倍率
        }
        
        // 升级赚钱效率
        float moneyUpgradeCost = baseMoneyUpgradeCost * pow(1.4f, runners.size());
        DrawText(TextFormat("Upgrade Money: $%.2f (x%.1f)", moneyUpgradeCost, moneyMultiplier), 150, 320, 20, WSP_WHITE);
        if (DrawButton(350, 310, 100, 40, "Upgrade", WSP_YELLOW) && money >= moneyUpgradeCost) {
            money -= moneyUpgradeCost;
            moneyMultiplier *= 1.3f; // 每次升级增加30%金钱倍率
        }
        
        // 监工升级（每升一级可以使1个小人永久自动跑圈）
        float foremanUpgradeCost = baseForemanUpgradeCost * pow(1.5f, foremanLevel);
        DrawText(TextFormat("Foreman Lv.%d: $%.2f", foremanLevel, foremanUpgradeCost), 150, 390, 20, WSP_WHITE);
        DrawText(TextFormat("Auto runners: %d/%d", GetAutoRunningCount(), runners.size()), 150, 420, 16, WSP_WHITE);
        if (DrawButton(350, 380, 100, 40, "Upgrade", WSP_GREEN) && money >= foremanUpgradeCost && GetAutoRunningCount() < runners.size()) {
            money -= foremanUpgradeCost;
            foremanLevel++;
            // 找到第一个非自动跑圈的小人，设置为自动跑圈
            for (auto& runner : runners) {
                if (!runner.isAutoRunning) {
                    runner.SetAutoRunning(true);
                    break;
                }
            }
        }
        
        // 关闭按钮
        if (DrawButton(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT - 150, 100, 40, "Close", WSP_RED)) {
            state = RUNNING;
        }
    }
};

int main() {
    // 初始化Raylib
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, GAME_TITLE);
    SetTargetFPS(60);
    
    // 创建游戏管理器
    GameManager game;
    
    // 游戏主循环
    while (!WindowShouldClose()) {
        // 更新游戏状态
        game.Update();
        
        // 绘制游戏画面
        BeginDrawing();
        ClearBackground(WSP_BLACK);
        game.Draw();
        EndDrawing();
    }
    
    // 关闭Raylib
    CloseWindow();
    return 0;
}