# Tasks: Refactor 150 lines

## 1. Tách calculate_service.dart (307 → 3 files)

- [ ] 1.1 Tạo `calculate_validator.dart` — validate main_data + mapping level_config (~80 lines)
- [ ] 1.2 Tạo `calculate_result_builder.dart` — tạo result records + tính payment_due_date (~80 lines)
- [ ] 1.3 Giữ `calculate_service.dart` — orchestrator + FIFO bonus logic (~150 lines)

## 2. Tách dashboard_screen.dart (300 → 3 files)

- [ ] 2.1 Tạo `widgets/step_card.dart` — StepCard widget (~60 lines)
- [ ] 2.2 Tạo `widgets/console_panel.dart` — Console log panel (~40 lines)
- [ ] 2.3 Giữ `dashboard_screen.dart` — state + layout + service calls (~150 lines)

## 3. Tách import_service.dart (163 → 2 files)

- [ ] 3.1 Tạo `import_main_data.dart` — dynamic header detection + main_data import (~90 lines)
- [ ] 3.2 Giữ `import_service.dart` — orchestrator + holiday/level import (~80 lines)

## 4. Verify

- [ ] 4.1 `dart analyze` pass
- [ ] 4.2 Không file nào > 150 lines (trừ .g.dart)
