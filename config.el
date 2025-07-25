;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Uni Marx"
      user-mail-address "uniwuni@protonmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-variable-pitch-font (font-spec :family "Noto Serif" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/workspace/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;



;; mixed pitch for org
(add-hook 'org-mode-hook #'mixed-pitch-mode)

;; generate agenda files dynamically to avoid org roam spam

(defun my/run-rg (pattern literal directory)
  (string-split (shell-command-to-string (concat "rg -l " (if literal "-F " "") "'" pattern "' '" (expand-file-name directory) "'")))
  )
(defun my/org-get-agenda-files ()
  (let* ((todos
          ;; all the potential TODO states
         (seq-map (apply-partially #'replace-regexp-in-string "(.*" "")
                  (seq-remove
                   (lambda (x) (or (string-equal "|" x) (eq x 'sequence)))
                   (apply #'append org-todo-keywords))))
         ;; each file that includes any of the todo states
         ;; might overshoot due to non todo mentions but who cares
         (files-todos (apply #'append
                             (seq-map (lambda (x) (my/run-rg x t org-directory)) todos
                              )) )
         ;; each file that contains something of the form [y-m-d] or <y-m-d>
         (date-todos (apply #'append
                             (seq-map (lambda (x) (my/run-rg x nil org-directory)) (list "<\\d\\d\\d\\d" "\\[\\d\\d\\d\\d")
                              )) ))
    (seq-filter (lambda (x) (or (string-suffix-p ".org" x) (string-suffix-p ".org-archive" x))) (append date-todos files-todos))
))
;; shift selection for org + setting the right agenda files even with org roam
(after! org (setq org-support-shift-select t)
        (advice-add #'org-agenda :before (lambda (&rest _args) (setq org-agenda-files (my/org-get-agenda-files))))
  )


; https://github.com/org-roam/org-roam-ui

(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start nil))

;; auto start roam ui
(add-hook 'org-mode-hook #'org-roam-ui-mode)

(map! :after org-roam
      :map org-mode-map
      "C-c j" #'org-roam-node-find ;; mnemonic: jump
      "C-c b" #'org-roam-node-insert ;; mnemonic: begin (one of the few that is free)
      "C-c i i" #'org-id-get-create ;; mnemonic: iid
      )
