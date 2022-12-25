;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Shamelessly copied from https://codingstruggles.com/emacs/resizing-windows-doom-emacs.html
(defhydra doom-window-resize-hydra (:hint nil)
  "
             _k_ increase height
_h_ decrease width    _l_ increase width
             _j_ decrease height
"
  ("h" evil-window-decrease-width)
  ("j" evil-window-increase-height)
  ("k" evil-window-decrease-height)
  ("l" evil-window-increase-width)

  ("q" nil))

(map! :after evil
      :m "j" #'evil-next-visual-line
      :m "k" #'evil-previous-visual-line)

(map!
    (:prefix "SPC w"
      :desc "Hydra resize" :n "SPC" #'doom-window-resize-hydra/body))

(after! latex
  (require' smartparens-latex)
  (defun sp-latex-insert-newline-inside-pair (_id action _context)
    "ID, ACTION, CONTEXT."
    (when (eq action 'insert)
      (insert "\n\n")
      (backward-char 1))
    (when (and (eq action 'wrap)
               (save-excursion
                 (goto-char (sp-get sp-last-wrapped-region :beg-in))
                 (not (sp--looking-back-p "[[{(]"))))
      (save-excursion
        (goto-char (sp-get sp-last-wrapped-region :end-in))
        (insert " ")
        (goto-char (sp-get sp-last-wrapped-region :beg-in))
        (insert " "))))

  (sp-with-modes '(latex-mode LaTeX-mode)
    (sp-local-pair "\\(" "\\)" :post-handlers '(sp-latex-insert-spaces-inside-pair))
    (sp-local-pair "\\[" "\\]"
                   :unless '(sp-latex-point-after-backslash)
                   :post-handlers '(sp-latex-insert-newline-inside-pair))
    )

  ;; (setq TeX-view-program-selection '(((output-dvi has-no-display-manager)
  ;;                                     "dvi2tty")
  ;;                                    ((output-dvi style-pstricks)
  ;;                                     "dvips and gv")
  ;;                                    (output-dvi "xdvi")
  ;;                                    (output-pdf "Evince")
  ;;                                    (output-html "xdg-open")))

  (use-package lsp-ltex
    :ensure t
    :hook (text-mode . (lambda ()
                         (require 'lsp-ltex)
                         (setq lsp-ltex-dictionary #s(hash-table size 30 data ("en-US" ["prefactor" "logarithmically" "Weyl" "eigenstate" "untilted"])))
                         )))  ; or lsp-deferred
  (use-package lsp-grammarly
    :ensure t
    :hook (text-mode . (lambda ()
                         (require 'lsp-grammarly)
                         (lsp))))  ; or lsp-deferred

  (use-package! laas
    :hook (LaTeX-mode . laas-mode)
    :config
    (setq laas-enable-auto-space nil)
    (add-to-list 'yas-before-expand-snippet-hook
                 (lambda() (smartparens-mode 'toggle)))

    (add-to-list 'yas-after-exit-snippet-hook
                 (lambda() (smartparens-mode 'toggle)))

    (aas-set-snippets 'laas-mode
      "<|" (lambda () (interactive)
             (yas-expand-snippet "\\braket{$1 | $2} $0"))
      :cond #'laas-object-on-left-condition
      "|>" (lambda () (interactive) (laas-wrap-previous-object "ket"))
      "sl" (lambda () (interactive) (laas-wrap-previous-object "slashed"))
      )
    )

  (require' cdlatex)
  (map! :map LaTeX-mode-map
        "$" nil
        "(" nil
        "{" nil
        "[" nil
        "|" nil
        "<" nil
        :i [tab] #'cdlatex-tab)
  )

(after! laas
  (aas-set-snippets 'laas-mode
    ;; set condition!
    :cond #'texmathp ; expand only while in math
    ;; bind to functions!
    "qq" (lambda () (interactive)
           (yas-expand-snippet "\\sqrt{$1 "))
    ;; add accent snippets
    :cond #'laas-object-on-left-condition
    ;; "qq" (lambda () (interactive) (laas-wrap-previous-object "sqrt"))
  )
)


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Thorvald Ballestad"
      user-mail-address "thorvald.tb@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
