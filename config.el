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
(require 'cl-lib)
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
                              )) )
         (todo-files (append date-todos files-todos))
         (todos-filtered (cl-set-difference todo-files (my/run-rg ":AGENDA_FILE:\s*f\s*$" nil org-directory) :test #'equal)))
    (seq-filter (lambda (x) (or (string-suffix-p ".org" x) (string-suffix-p ".org-archive" x))) todos-filtered)
))
;; shift selection for org + setting the right agenda files even with org roam
(after! org (setq org-support-shift-select t)
        (advice-add #'org-agenda :before (lambda (&rest _args) (setq org-agenda-files (my/org-get-agenda-files))))

        ;; publishing
        (setq org-html-html5-fancy t)
        (setq org-html-doctype "html5")
        (setq org-export-headline-levels 15)
        (setq org-html-mathjax-template
              "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/katex.min.css\" integrity=\"sha384-5TcZemv2l/9On385z///+d7MSYlvIEw9FuZTIdZ14vJLqWphw7e7ZPuOiCHJcFCP\" crossorigin=\"anonymous\">


              <script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/katex.min.js\" integrity=\"sha384-cMkvdD8LoxVzGF/RPUKAcvmm49FQ0oxwDF3BGKtDXcEc+T1b2N+teh/OJfpU0jr6\" crossorigin=\"anonymous\"></script>

              <script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/contrib/auto-render.min.js\" integrity=\"sha384-hCXGrW6PitJEwbkoStFjeJxv+fSOOQKOPbJxSfM6G5sWZjAyWhXiTIIAmQqnlLlh\" crossorigin=\"anonymous\"
             onload=\"renderMathInElement(document.body, {&quot;trust&quot;: true, &quot;globalGroup&quot;: true});\"></script>")
        (setq org-html-head
              "<style>
               a:link { color: #211d94 }
               a:visited { color: #312da4 }
a:link {
  text-decoration: none;
}

a:visited {
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

a:active {
  text-decoration: underline;
}
:target {
  position: relative;
}
:target::before {
  content: \"🐇\";
  position: absolute;
  left: -0.5em; transform: translateX(-100%);
}
div.tag-proof::after{

  content: '□';
  line-height: 100%;
  position: absolute;
  display: inline;
  right: 0;
  bottom: 0;
}
div.tag-definition { padding: 10px; border: 2px solid green; margin: 5px; background-color: #cfc; border-radius: 12px; }
div.tag-notation { padding: 10px; border: 2px solid gray; margin: 5px; background-color: #ccc; border-radius: 12px; }
div.tag-proposition { padding: 10px; border: 2px solid blue; margin: 5px;background-color: #ccf; border-radius: 12px; }
div.tag-remark { padding: 10px; border: 2px solid red; margin: 5px; background-color: #eae; border-radius: 12px; }
div.tag-example { padding: 10px; border: 2px solid red; margin: 5px; background-color: #e9a; border-radius: 12px; }
div.tag-theorem { padding: 10px; border: 2px solid yellow; margin: 5px; background-color: #eea; border-radius: 12px; }
div.tag-lemma { padding: 10px; border: 2px solid orange; margin: 5px; background-color: #fcc; border-radius: 12px; }
div.tag-proof, div.tag-proofsketch { position: relative; padding: 10px; border: 1px solid grey; background-color: rgba(255,255,255, 0.5) }
h1.tag-proof,  h2.tag-proof,  h3.tag-proof,  h4.tag-proof,  h5.tag-proof,  h6.tag-proof,  h7.tag-proof,  h8.tag-proof,  h1.tag-proofsketch,  h2.tag-proofsketch,  h3.tag-proofsketch,  h4.tag-proofsketch,  h5.tag-proofsketch,  h6.tag-proofsketch,  h7.tag-proofsketch, h8.tag-proofsketch {
  font-variant-caps: small-caps;
}
.quiver-embed {margin: auto; display: block}
.backlink-details[open] {max-height: 200px; overflow-y: auto;}
.backlink-details > summary {line-height: 100%}
.backlink-details[open] > summary {margin-bottom: 0.3em}
.backlink-details {max-height: auto; margin-bottom: 0.3em}
.backlink-details > p {font-size: 80%; display: inline-block; margin: 0}
.backlink-details > p:nth-child(-n+3) {display: none}
.backlink-details > p:nth-child(n+4)::before { content: ' • '; color: grey }
               </style>")
        (setq org-publish-project-alist
              '(("roam"
                 :base-directory "~/workspace/roam/"
                 :publishing-directory "~/workspace/roam-publish"
                 :auto-sitemap t)))
        (defun my/org-html-headline (headline contents info)
  "Transcode a HEADLINE element from Org to HTML.
CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  (unless (org-element-property :footnote-section-p headline)
    (let* ((numberedp (org-export-numbered-headline-p headline info))
           (numbers (org-export-get-headline-number headline info))
           (level (+ (org-export-get-relative-level headline info)
                     (1- (plist-get info :html-toplevel-hlevel))))
           (todo (and (plist-get info :with-todo-keywords)
                      (let ((todo (org-element-property :todo-keyword headline)))
                        (and todo (org-export-data todo info)))))
           (todo-type (and todo (org-element-property :todo-type headline)))
           (priority (and (plist-get info :with-priority)
                          (org-element-property :priority headline)))
           (text (org-export-data (org-element-property :title headline) info))
           (tags (and (plist-get info :with-tags)
                      (org-export-get-tags headline info)))
           (full-text (funcall (plist-get info :html-format-headline-function)
                               todo todo-type priority text tags info))
           (contents (or contents ""))
	   (id (org-html--reference headline info))
	   (formatted-text
	    (if (plist-get info :html-self-link-headlines)
		(format "<a href=\"#%s\">%s</a>" id full-text)
	      full-text)))
      (if (org-export-low-level-p headline info)
          ;; This is a deep sub-tree: export it as a list item.
          (let* ((html-type (if numberedp "ol" "ul")))
	    (concat
	     (and (org-export-first-sibling-p headline info)
		  (format "<%s class=\"org-%s %s\">\n"
			 html-type
                         html-type
                         (mapconcat (lambda (tag) (concat "tag-" tag " ")) tags)))
	     (org-html-format-list-item
	      contents (if numberedp 'ordered 'unordered)
	      nil info nil
	      (concat (org-html--anchor id nil nil info) formatted-text)) "\n"
	     (and (org-export-last-sibling-p headline info)
		  (format "</%s>\n" html-type))))
	;; Standard headline.  Export it as a section.
        (let ((extra-class
	       (org-element-property :HTML_CONTAINER_CLASS headline))
	      (headline-class
	       (org-element-property :HTML_HEADLINE_CLASS headline))
              (first-content (car (org-element-contents headline))))
          (format "<%s id=\"%s\" class=\"%s %s\">%s%s</%s>\n"
                  (org-html--container headline info)
                  (format "outline-container-%s" id)
                  (concat (format "outline-%d" level)
                          (and extra-class " ")
                          extra-class)
                  (mapconcat (lambda (tag) (concat "tag-" tag " ")) tags)
                  (format "\n<h%d id=\"%s\" class=\"%s\">%s</h%d>\n"
                          level
                          id
			  (if (not headline-class) (mapconcat (lambda (tag) (concat "tag-" tag " ")) tags)
			    (format "%s %s" headline-class (mapconcat (lambda (tag) (concat "tag-" tag " ")) tags)))
                          (concat
                           (and numberedp
                                (format
                                 "<span class=\"section-number-%d\">%s</span> "
                                 level
                                 (concat (mapconcat #'number-to-string numbers ".") ".")))
                           formatted-text)
                          level)
                  ;; When there is no section, pretend there is an
                  ;; empty one to get the correct <div
                  ;; class="outline-...> which is needed by
                  ;; `org-info.js'.
                  (if (org-element-type-p first-content 'section) contents
                    (concat (org-html-section first-content "" info) contents))
                  (org-html--container headline info)))))))
        (advice-add 'org-html-headline :override #'my/org-html-headline)

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
(add-hook 'org-mode-hook (lambda () (if (not org-roam-ui-mode) (org-roam-ui-mode))))
(add-hook 'org-mode-hook (lambda () (require 'org-roam-export)))



(map! :after org-roam
      :map org-mode-map
      "C-c j" #'org-roam-node-find ;; mnemonic: jump
      "C-c b" #'org-roam-node-insert ;; mnemonic: begin (one of the few that is free)
      "C-c i i" #'org-id-get-create ;; mnemonic: iid
      "C-c i p" #'my/make-proof ;; insert proof
      )



(defun my/make-proof ()
  (interactive)
  (org-id-get-create)
  (let ((id (org-id-get nil))
        (title (save-excursion
                 (outline-previous-heading)
                 (org-element-property :title (org-element-at-point))
                 ))
        )
    (org-insert-subheading nil)
    (insert "proof of ")
    (insert (concat "[[id:" id "][" title "]] :proof:" "\n"))
    (org-id-get-create)
    ))

;; koma articles
(with-eval-after-load "ox-latex"
  (add-to-list 'org-latex-classes
               '("koma-article" "\\documentclass{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))


;; backlinks
(defun collect-backlinks-string (backend)
  (when (and (org-roam-node-at-point) (equal backend 'html))
    (let* ((nodes-in-file (let ((-compare-fn (lambda (x y) (equal (org-roam-node-id x) (org-roam-node-id y)))))
                            (-uniq (--filter (s-equals? (org-roam-node-file it) (org-roam-node-file (org-roam-node-at-point)))
                                    (org-roam-node-list)))))
           (nodes-start-position (-map 'org-roam-node-point nodes-in-file))
           ;; Nodes don't store the last position, so get the next headline position
           ;; and subtract one character (or, if no next headline, get point-max)
           (nodes-end-position (-map (lambda (nodes-start-position)
                                       (goto-char nodes-start-position)
                                       (if (org-before-first-heading-p) ;; file node
                                           (point-max)
                                         (call-interactively
                                          'org-next-visible-heading)
                                         (if (> (point) nodes-start-position)
                                             (- (point) 1) ;; successfully found next
                                           (point-max)))) ;; there was no next
                                     nodes-start-position))
           ;; sort in order of decreasing end position
           (nodes-in-file-sorted (->> (-zip-pair nodes-in-file nodes-end-position)
                                      (--sort (> (cdr it) (cdr other))))))
      (dolist (node-and-end nodes-in-file-sorted)
        (-let (((node . end-position) node-and-end))
          (when (org-roam-backlinks-get node)
            (goto-char end-position)
            ;; Add the references as a subtree of the node
            (insert
             "
#+attr_html: :class backlink-details
#+begin_details
@@html:<summary>@@Backlinks@@html:</summary>@@

"
             )
            (dolist (backlink (org-roam-backlinks-get node :unique t))
              (let* ((source-node (org-roam-backlink-source-node backlink))
                     ;(properties (org-roam-backlink-properties backlink))
                     ;(outline (when-let ((outline (plist-get properties :outline)))
                     ;             (mapconcat #'org-link-display-format outline " > ")))
;                     (point (org-roam-backlink-point backlink))
                     ;(text (s-replace "\n" " " (org-roam-preview-get-contents
                     ;                           (org-roam-node-file source-node)
                     ;                           point)))
                     (reference (format "[[id:%s][%s]]\n\n"
                                        (org-roam-node-id source-node)
                                        (org-roam-node-title source-node)

                                        )))
                (insert reference)))
            (insert "\n#+end_details\n")))))))
(add-hook 'org-export-before-processing-functions 'collect-backlinks-string)
