;;; init-org.el --- Integrated Org-mode configuration -*- lexical-binding: t -*-

;;; Commentary:
;; 整合了现代化 UI (org-modern)、双链笔记 (org-roam)、
;; 强化版中文 LaTeX 导出以及高效的 GTD 工作流。

;;; Code:

;; =============================================================================
;; 1. 基础路径与全局变量 (核心目录建议统一)
;; =============================================================================
(setq org-directory "~/org/") ; 建议所有 org 文件放在此处
(setq org-roam-directory (expand-file-name "roam/" org-directory))

;; 确保目录存在
(unless (file-exists-p org-directory)
  (make-directory org-directory t))

;; =============================================================================
;; 2. Org 核心配置 (使用 straight.el + use-package)
;; =============================================================================
(use-package org
  :straight t
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c b" . org-switchb))
  :hook ((org-mode . visual-line-mode)
         (org-mode . flyspell-mode)
         (org-mode . org-modern-mode)) ; 启用现代视觉效果
  :config
  ;; 基础行为设置 (来自 V2)
  (setq org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        org-hide-emphasis-markers t
        org-ellipsis "…" 
        org-export-with-smart-quotes t)

  ;; TODO 状态与颜色 (来自 V2 强化版)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "STARTED(s!)" "WAITING(w@/!)" "HOLD(h)" "|" "DONE(d!)" "CANCELLED(c@)")))

  (setq org-todo-keyword-faces
        '(("TODO" . (:foreground "red" :weight bold))
          ("STARTED" . (:foreground "orange" :weight bold))
          ("WAITING" . (:foreground "magenta" :weight bold))
          ("HOLD" . (:foreground "gray" :weight bold))
          ("DONE" . (:foreground "forest green" :weight bold))
          ("CANCELLED" . (:foreground "dim gray" :weight bold))))

  ;; Agenda 设置 (来自 V1 & V2 融合)
  (setq org-agenda-files (list org-directory)) ; 扫描整个 org 目录
  (setq org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string "◀── now ─────────────────────────────────────────────────")

  ;; 快捷输入模板 (<s 展开代码块)
  (require 'org-tempo))

;; =============================================================================
;; 3. 视觉增强 (Org-Modern)
;; =============================================================================
(use-package org-modern
  :straight t
  :config
  (setq org-modern-star '("◉" "○" "◈" "◇" "✳") ; 美化标题星星
        org-modern-table-vertical 1
        org-modern-variable-pitch nil)
  (global-org-modern-mode))

;; =============================================================================
;; 4. 捕获与重构 (Capture & Refile)
;; =============================================================================
(setq org-capture-templates
      `(("t" "Todo" entry
         (file ,(expand-file-name "inbox.org" org-directory))
         "* TODO %?\n  SCHEDULED: %t\n  %i\n  %a")
        ("n" "Note" entry
         (file ,(expand-file-name "notes.org" org-directory))
         "* %?\n  %U\n  %i\n  %a")
        ("d" "Diary" entry
         (file+datetree ,(expand-file-name "diary.org" org-directory))
         "* %?\n  Entered on %U\n")))

(setq org-refile-targets '((nil :maxlevel . 3)
                           (org-agenda-files :maxlevel . 3)))
(setq org-outline-path-complete-in-steps nil) ; 一次性选择路径
(setq org-refile-use-outline-path 'file)

;; =============================================================================
;; 5. LaTeX 中文导出增强 (来自 V2 核心精华)
;; =============================================================================
(use-package ox-latex
  :straight nil
  :after org
  :config
  (setq org-latex-compiler "xelatex")
  
  ;; Ctexart 类设置
  (add-to-list 'org-latex-classes
               '("ctexart"
                 "\\documentclass[11pt]{ctexart}
                  \\usepackage[a4paper,margin=2.5cm]{geometry}
                  \\usepackage{amsmath,amssymb}
                  \\usepackage{fontspec}
                  \\usepackage{unicode-math}
                  \\usepackage{hyperref}
                  \\hypersetup{colorlinks=true, linkcolor=blue, urlcolor=blue}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

  ;; Beamer (幻灯片) 设置
  (add-to-list 'org-latex-classes
               '("beamer"
                 "\\documentclass[11pt]{beamer}
                  \\usetheme{Madrid}
                  \\usepackage{ctex}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")))

  (setq org-latex-default-class "ctexart")
  (setq org-latex-pdf-process
        '("xelatex -interaction nonstopmode -output-directory %o %f"
          "bibtex %b"
          "xelatex -interaction nonstopmode -output-directory %o %f"
          "xelatex -interaction nonstopmode -output-directory %o %f")))

;; =============================================================================
;; 6. 知识管理 (Org-roam v2)
;; =============================================================================
(use-package org-roam
  :straight t
  :init
  (setq org-roam-v2-ack t)
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n l" . org-roam-buffer-toggle))
  :config
  (org-roam-db-autosync-mode))

(provide 'init-org)
;;; init-org.el ends here
