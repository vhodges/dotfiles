;; emacs configuration
;; from: http://viget.com/extend/emacs-24-rails-development-environment-from-scratch-to-productive-in-5-minu

(push "/usr/local/bin" exec-path)
(add-to-list 'load-path "~/.emacs.d/lisp")

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq inhibit-startup-message t)

(fset 'yes-or-no-p 'y-or-n-p)

(delete-selection-mode t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode t)
(show-paren-mode t)
(column-number-mode t)
(line-number-mode t)

;; These only exist for GUI'd env's
;(scroll-bar-mode -1)
;(tool-bar-mode -1)
;(set-fringe-style -1)
;(tooltip-mode -1)

(ido-mode t)
;;(require 'tomorrow-night-bright-theme)
;;(load-theme 'tomorrow-night-bright t)
(load-theme 'wombat t)

(add-to-list 'custom-theme-load-path "~/.emacs.d/lisp/")

(defun ruby-mode-hook ()
  (autoload 'ruby-mode "ruby-mode" nil t)
  (add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))
  (add-to-list 'auto-mode-alist '("\\.ru\\'" . ruby-mode))
  (add-hook 'ruby-mode-hook '(lambda ()
                               (setq ruby-deep-arglist t)
                               (setq ruby-deep-indent-paren nil)
                               (setq c-tab-always-indent nil)
                               (require 'inf-ruby)
                               (require 'ruby-compilation)
                               (define-key ruby-mode-map (kbd "M-r") 'run-rails-test-or-ruby-buffer))))

(defun yaml-mode-hook ()
  (autoload 'yaml-mode "yaml-mode" nil t)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode)))

(defun css-mode-hook ()
  (autoload 'css-mode "css-mode" nil t)
  (add-hook 'css-mode-hook '(lambda ()
                              (setq css-indent-level 2)
                              (setq css-indent-offset 2))))
(defun is-rails-project ()
  (when (textmate-project-root)
    (file-exists-p (expand-file-name "config/environment.rb" (textmate-project-root)))))

(defun run-rails-test-or-ruby-buffer ()
  (interactive)
  (if (is-rails-project)
      (let* ((path (buffer-file-name))
             (filename (file-name-nondirectory path))
             (test-path (expand-file-name "test" (textmate-project-root)))
             (command (list ruby-compilation-executable "-I" test-path path)))
        (pop-to-buffer (ruby-compilation-do filename command)))
    (ruby-compilation-this-buffer)))

;; Enable mouse support
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] '(lambda ()
                              (interactive)
                              (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda ()
                              (interactive)
                              (scroll-up 1)))
  (defun track-mouse (e))
  (setq mouse-sel-mode t)

  ;;(set-frame-font "Menlo-12")
)


(require 'package)
(setq package-archives (cons '("tromey" . "http://tromey.com/elpa/") package-archives))
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

(setq el-get-sources
      '((:name ruby-mode 
               :type elpa
               :load "ruby-mode.el"
               :after (lambda () (ruby-mode-hook)))
        (:name inf-ruby  :type elpa)
        (:name ruby-compilation :type elpa)
        (:name css-mode 
               :type elpa 
               :after (lambda () (css-mode-hook)))
        (:name textmate
               :type git
               :url "git://github.com/defunkt/textmate.el"
               :load "textmate.el")
        ;; (:name rvm
        ;;        :type git
        ;;        :url "http://github.com/djwhitt/rvm.el.git"
        ;;        :load "rvm.el"
        ;;        :compile ("rvm.el")
        ;;        :after (progn () (rvm-use-default)))
        (:name haml-mode :type git
               :url "https://github.com/nex3/haml-mode.git")
        (:name sass-mode
               :type git
               :load "sass-mode.el"
               :url "https://github.com/nex3/sass-mode.git"
               :after (lambda() (sass-mode-hook )))
        (:name yaml-mode 
               :type git
               :url "http://github.com/yoshiki/yaml-mode.git"
               :features yaml-mode
               :after (lambda () (yaml-mode-hook)))
	))
(el-get 'sync)

(setq magit-status-buffer-switch-function 'switch-to-buffer)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)


(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

;(require 'go-autocomplete)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)



;; To install go-mode, add the following lines to your .emacs file:
;(add-to-list 'load-path "/usr/local/go/misc/emacs" t)
;(require 'go-mode-load)

;(require 'go-eldoc)
;(add-hook 'go-mode-hook 'go-eldoc-setup)

(setq exec-path (cons "/usr/local/go/bin" exec-path))
(add-to-list 'exec-path "/Users/vhodges/go/bin")
(add-hook 'before-save-hook 'gofmt-before-save)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("ef04dd1e33f7cbd5aa3187981b18652b8d5ac9e680997b45dc5d00443e6a46e3" "6f3e8df833cdaaef4ae0fb5cad70f5f74afc834a5eb8eec45efa5dd8f7356f9d" "b3bcf1b12ef2a7606c7697d71b934ca0bdd495d52f901e73ce008c4c9825a3aa" "fc7fd2530b82a722ceb5b211f9e732d15ad41d5306c011253a0ba43aaf93dccc" "44ea93c9b259bb6aaa1f44d9a241046cffeea66654abc3fe41d9c49577e30d3c" "eae831de756bb480240479794e85f1da0789c6f2f7746e5cc999370bbc8d9c8a" "840db7f67ce92c39deb38f38fbc5a990b8f89b0f47b77b96d98e4bf400ee590a" "12670281275ea7c1b42d0a548a584e23b9c4e1d2dabb747fd5e2d692bcd0d39b" "78c1c89192e172436dbf892bd90562bc89e2cc3811b5f9506226e735a953a9c6" "db2ecce0600e3a5453532a89fc19b139664b4a3e7cbefce3aaf42b6d9b1d6214" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "c05b3e1761ba96b8169e62fd9c1a7359844a4c274f6879b6105984719f5fe8d7" "3fd0fda6c3842e59f3a307d01f105cce74e1981c6670bb17588557b4cebfe1a7" "bc40f613df8e0d8f31c5eb3380b61f587e1b5bc439212e03d4ea44b26b4f408a" "344ff60900acf388116822a0540b34699fc575cf29a5c9764453d045cc42a476" "935e766f12c5f320c360340c8d9bc1726be9f8eb01ddeab312895487e50e5835" "e39634a794245b1921e34f0d1da169b564d5d1bc18190970d79ecca251d0ee62" "ba462e70a4ae40275d6c83b38b17070a8d8327a815375f3c70924c3b332dd8e2" default)))
 '(package-selected-packages
   (quote
    (base16-theme aurora-theme arjen-grey-theme solarized-theme darktooth-theme xterm-frobs gruvbox-theme soothe-theme zenburn web-mode magit go-eldoc)))
 '(safe-local-variable-values
   (quote
    ((eval setq default-directory
           (concat
            (locate-dominating-file buffer-file-name ".dir-locals.el")
            "/src"))
     (eval setq default-directory
           (locate-dominating-file buffer-file-name ".dir-locals.el"))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq ispell-program-name "aspell")
(setq ispell-list-command "list")

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(setq compilation-read-command nil)

(defun toggle-camelcase-underscores ()
  "Toggle between camcelcase and underscore notation for the symbol at point."
  (interactive)
  (save-excursion
    (let* ((bounds (bounds-of-thing-at-point 'symbol))
           (start (car bounds))
           (end (cdr bounds))
           (currently-using-underscores-p (progn (goto-char start)
                                                 (re-search-forward "_" end t))))
      (if currently-using-underscores-p
          (progn
            (upcase-initials-region start end)
            (replace-string "_" "" nil start end)
            (downcase-region start (1+ start)))
        (replace-regexp "\\([A-Z]\\)" "_\\1" nil (1+ start) end)
        (downcase-region start end)))))

(global-set-key (kbd "C-c m") 'compile)
