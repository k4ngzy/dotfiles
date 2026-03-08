;;; init-auto-pairs.el --- Lightweight auto-pairing  -*- lexical-binding: t; -*-

;; 启用内置的自动配对
(electric-pair-mode 1)

;; 全局配置
(setq electric-pair-preserve-balance t       ; 保持括号平衡
      electric-pair-delete-adjacent-pairs t  ; 删除时同时删除配对括号
      electric-pair-open-newline-between-pairs t) ; 支持换行

;; Python 模式下的增强配置
(defun my/python-electric-pair-setup ()
  "Python-specific electric pair configuration."
  ;; 添加 Python 特有的配对
  (setq-local electric-pair-pairs
              (append electric-pair-pairs
                      '((?\' . ?\')   ; 单引号
                        (?\" . ?\")   ; 双引号
                        (?\` . ?\`)))) ; 反引号
  
  ;; 智能跳过引号 (在字符串内不自动配对)
  (setq-local electric-pair-skip-self 'electric-pair-default-skip-self))

;; 在括号内按 RET 自动换行并缩进
(defun my/electric-pair-ret ()
  "When RET is pressed between pairs, add newline and indent."
  (interactive)
  (let ((between-pairs
         (and (char-before)
              (char-after)
              (or (and (eq (char-before) ?\{) (eq (char-after) ?\}))
                  (and (eq (char-before) ?\[) (eq (char-after) ?\]))
                  (and (eq (char-before) ?\() (eq (char-after) ?\)))
                  (and (eq (char-before) ?\") (eq (char-after) ?\"))
                  (and (eq (char-before) ?\') (eq (char-after) ?\'))))))
    (if between-pairs
        (progn
          (newline)
          (indent-according-to-mode)
          (forward-line -1)
          (end-of-line)
          (newline)
          (indent-according-to-mode))
      (newline-and-indent))))

(add-hook 'python-mode-hook
          (lambda ()
            (my/python-electric-pair-setup)
            (local-set-key (kbd "RET") 'my/electric-pair-ret)))

(add-hook 'prog-mode-hook
          (lambda ()
            (local-set-key (kbd "RET") 'my/electric-pair-ret)))

(provide 'init-sp)
