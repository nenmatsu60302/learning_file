# Copilot / AI agent 指南（自動產生草案）

注意：目前倉庫沒有原始程式碼或說明檔（empty repository）。此檔為 AI 程式碼代理人（Copilot style agent）的操作指南草案，目的是當專案內容出現時，能快速導引代理人採取可重複的發現與修改步驟。

1) 首要檢查（序列化步驟）
- 列出頂層檔案與資料夾：檢查是否有 `README.md`, `Makefile`, `CMakeLists.txt`, `package.json`, `requirements.txt`。
- 搜尋硬體專案慣用檔：`*.v`, `*.sv`, `*.vh`, `*.xdc`, `*.sdc`, `*.tcl`，以及 `constraints/`, `fpga/`, `hw/`, `sw/`, `tools/` 目錄。
- 搜尋 CI 配置檔：`.github/workflows/**`。

2) 如果倉庫為空（當前情況）
- 創建或更新 `README.md`，向使用者確認專案目標（FPGA / 軟體 / 混合），並要求提供：主要語言、建置步驟、目標硬體、測試指令。
- 建議新增最小 CI（`.github/workflows/ci.yml`）範本，先以 lint 或檢查檔案格式為主，等待使用者確認後再擴充。

3) 分析已存在專案時要找的「重要檔案/模式」
- Build: `Makefile` 或 `CMakeLists.txt`，找出主要目標（target）與環境變數（例：`VIVADO_HOME`, `PATH`）。
- Toolchain scripts: `scripts/` 中的 `build_*.sh` 或 `*.tcl`（平台啟動、bitstream 產生步驟）。
- Constraints: `*.xdc` 或 `*.sdc` 放在 `constraints/` 或 `fpga/` 下。
- Tests: `tests/` 或 `sim/` 內的模擬腳本（如使用 `iverilog`, `verilator` 或 vendor simulator）。
- Entry points: 軟體部分的 `src/main.*` 或 `app/`；硬體部分的 `top.*` 或 `top.sv`。

4) 寫補案/修改時的具體建議（保守原則）
- 若不確定建置命令，不主動執行建置與部署；先在 PR 中以摘要詢問使用者或在 issue 注記需的環境變數與工具版本。
- 變更範圍應以小步驟為主：新增 README → 新增 CI skeleton → 新增簡單腳本或範例。在提交前請執行本地 lint 或最小語法檢查（若能自動執行）。

5) 風格與命名約定（可被發現的實例）
- FPGA/hw 檔案常見副檔名：`.v`, `.sv`；constraints 放 `*.xdc`。
- 腳本與工具通常放 `scripts/` 或 `tools/`。
- 若出現 `platforms/` 或 `boards/` 資料夾，視為多板支援，對每個板子應有獨立 constraints 與 README。

6) 與外部整合點（發現時記錄）
- Vendor tools：Xilinx/Vivado、Intel/Quartus 等，檔案或腳本通常會提及 `vivado`, `quartus`。檢測這類關鍵字以判定所需工具。
- 外部 services：若有 `docker/` 或 `Dockerfile`，優先使用 container 化建置以避免環境差異。

7) 提交與溝通（PR 範例）
- PR 標題：簡潔描述變更，例如 "docs: add README skeleton and CI"。
- PR 內容包含：變更摘要、為何要改（背景）、如何驗證（commands）、需要使用者提供的資訊（如果有）。

8) 當你需要更多資訊時要問的具體問題（範例）
- 專案目標是什麼（FPGA bitstream / 軟體 / demo）？
- 主要開發語言與工具鏈（例如 Vivado 2021.2、Verilator 4.0）？
- 是否需要支援 CI（GitHub Actions）自動建置？

---

如果你希望我把此草案調整為英文版、加入 CI 範本或依照你具體的專案檔案自動填入細節，請回覆並上傳或初始化一些核心檔案（例如 `README.md`、`Makefile`、或一個 `fpga/` 目錄），我會基於那些檔案進行下一輪具體化修改。
