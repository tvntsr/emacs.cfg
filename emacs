;;;; Hide tool bar
(tool-bar-mode -1)
(load-theme 'wombat)

;;; Default shortcuts
(setq-default indent-tabs-mode nil)
(setq default-tab-width 4)
(global-set-key "\M-?" 'goto-line)
(global-set-key (kbd "<C-return>") 'set-mark-command)

(setq-default c-basic-offset 4
        tab-width 4
        indent-tabs-mode t)

(global-set-key (kbd "M-*") 'pop-tag-mark)

(global-set-key (kbd "C-c C-c") 'comment-region)

(global-set-key (kbd "M-*") 'pop-tag-mark)

;;; package manager
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;;(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)
(package-initialize)

(require 'use-package)

;;;(require 'function-args)
;;;(fa-config-default)

(require 'ggtags)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))

;;
(require 'company-go)
(push 'company-lsp company-backends)

(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)

;; Origami - Does code folding, ie hide the body of an
;; if/else/for/function so that you can fit more code on your screen
(use-package origami
  :ensure t
  :commands (origami-mode)
  :hook (prog-mode . origami-mode)
  :bind (:map origami-mode-map
              ("C-c o :" . origami-recursively-toggle-node)
              ("C-c o a" . origami-toggle-all-nodes)
              ("C-c o t" . origami-toggle-node)
              ("C-c o o" . origami-show-only-node)
              ("C-c o u" . origami-undo)
              ("C-c o U" . origami-redo)
              ("C-c o C-r" . origami-reset)
              )
;;  :hydra (hydra-origami (:color pink :columns 4)
;;                        "Origami Folds"
;;                        ("t" origami-recursively-toggle-node "Toggle")
;;                        ("s" origami-show-only-node "Single")
;;                        ("r" origami-redo "Redo")
;;                        ("u" origami-undo "Undo")
;;                        ("o" origami-open-all-nodes "Open")
;;                        ("c" origami-close-all-nodes "Close")
;;                        ("n" origami-next-fold "Next")
;;                        ("p" origami-previous-fold "Previous")
;;                        ("q" nil "Quit" :color blue)
;;                        ("g" nil "cancel" :color blue))
  :config
  (setq origami-show-fold-header t)
  ;; The python parser currently doesn't fold if/for/etc. blocks, which is
  ;; something we want. However, the basic indentation parser does support
  ;; this with one caveat: you must toggle the node when your cursor is on
  ;; the line of the if/for/etc. statement you want to collapse. You cannot
  ;; fold the statement by toggling in the body of the if/for/etc.
  (add-to-list 'origami-parser-alist '(python-mode . origami-indent-parser))
  )

;; Modern C++ code highlighting
(use-package modern-cpp-font-lock
  :ensure t
  :diminish modern-c++-font-lock-mode
  :hook (c++-mode . modern-c++-font-lock-mode)
  :init
  (eval-when-compile
      ;; Silence missing function warnings
    (declare-function modern-c++-font-lock-global-mode
                      "modern-cpp-font-lock.el"))
  :config
  (modern-c++-font-lock-global-mode t)
  )

;; json
;; (require 'json-mode)
(add-hook 'json-mode-hook #'flycheck-mode)
(add-hook 'json-mode-hook #'display-line-numbers-mode)


(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.gfm\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.apib\\'" . markdown-mode)  ; Apiary
         ("\\.markdown\\'" . markdown-mode))
;;  :config (progn
;;            ;; Markdown-cycle behaves like org-cycle, but by default is only
;;            ;; enabled in insert mode. gfm-mode-map inherits from
;;            ;; markdown-mode-map, so this will enable it in both.
;;            (evil-define-key 'normal markdown-mode-map
;;              (kbd "TAB") 'markdown-cycle
;;              "gk" 'markdown-previous-visible-heading
;;              "gj" 'markdown-next-visible-heading))
)

;; Docker
(use-package dockerfile-mode)
(use-package docker-compose-mode
  :mode "docker-compose\\'")

;; YAML
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :hook
  (yaml-mode . highlight-indent-guides-mode)
  (yaml-mode . display-line-numbers-mode))

(use-package which-key)
(which-key-mode)

;; lsp-mode
(use-package lsp-mode
    :commands (lsp lsp-deferred)
    :init
        (setq lsp-keymap-prefix "C-c l")
    :config
        (lsp-enable-which-key-integration t)
    :hook (
        (go-mode . lsp)
        (c-mode . lsp)
        (c++-mode . lsp)
        (python-mode . lsp) ;; pip install "python-lsp-server[all]"
       )
)

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(defun f-go-mode-hook ()
    (local-set-key (kbd "C-c C-c") 'comment-region)
)
(add-hook 'go-mode-hook #'f-go-mode-hook)

;; Set up before-save hooks to format buffer and add/delete imports.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Start LSP Mode and YASnippet mode
(add-hook 'go-mode-hook #'lsp-deferred)
(add-hook 'go-mode-hook #'yas-minor-mode)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
      (setq lsp-ui-doc-enable t))

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list)


;; To set the garbage collection threshold to high (100 MB) since LSP client-server communication generates a lot of output/garbage
;; (setq gc-cons-threshold 100000000)
;; To increase the amount of data Emacs reads from a process
;; (setq read-process-output-max (* 1024 1024)) 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(yaml-mode lsp-ui origami json-mode smex counsel cmake-mode yasnippet use-package lsp-mode ggtags company-go)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; (setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs helm-lsp
;;    projectile hydra flycheck company avy which-key helm-xref dap-mode))

;; (when (cl-find-if-not #'package-installed-p package-selected-packages)
;;  (package-refresh-contents)
;;  (mapc #'package-install package-selected-packages))

;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details

;; (which-key-mode)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
;; (require 'dap-cpptools)
  (yas-global-mode))

