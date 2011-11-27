;;; XDG Base Directory Specification paths for emacs.
;;;
;;;
;;; Copyright ©2011 Francisco Miguel Colaço <francisco.colaco@gmail.com>
;;; All rights reserved.
;;;
;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public
;;; License as published by the Free Software Foundation; either
;;; version 3 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this library; if not, write to the
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;;; Boston, MA 02111-1307, USA.
;;;
;;;
;;; Commentary:
;;;
;;; This package sets the directory according to the XDG Base
;;; Directory Specification.  The directories are given by the
;;; environment variables, falling back to the defaults enumerated
;;; in the standard.
;;;
;;; The $XDG_RUNTIME_DIR was not contemplated here, since we found
;;; no practical use for it.
;;;
;;; The defaults (or generated values) are:
;;;
;;;          Symbol                         Default
;;;  user-emacs-data-directory     ~/.local/share/emacs/
;;;  user-emacs-config-directory   ~/.config/emacs/
;;;  user-emacs-cache-directory    ~/.cache/emacs/
;;;  user-emacs-lisp-directory     `user-emacs-data-directory`/lisp
;;;  user-documents-directory      ~/Documents
;;;
;;; Some convenience functions are defined to locate files in these
;;; directories and to add user lisp to load-path.
;;;
;;; Some advantages are:
;;;
;;; Installation:
;;;
;;;   1. put xdg-paths in your own path.
;;;   2. Start your .emacs with (load-library 'xdg-paths) or,
;;;      write (load-library 'xdg-paths) in site-start.el
;;;
;;; Use cases:
;;;
;;; In my .emacs, I simply load a configuration hub file within
;;; user-emacs-config-directory with:
;;;
;;;   (load (locate-user-config-file "conf-init"))
;;;
;;; Within conf-init.el file, all other files are loaded with:
;;;
;;;   (dolist (module (list
;;;                    "edit" "frame" "programming" "tex" "xml"
;;;                    (concat "emacs-version-" (int-to-string emacs-major-version))
;;;                    (concat "window-system-" (symbol-name window-system))
;;;                    (concat "system-type-" (subst-char-in-string ?/ ?- (symbol-name system-type)))
;;;                    (concat "host-" (system-name))))
;;;     (load (locate-user-config-file (concat "conf-" module)) t))
;;;
;;; Adding to path from the user library just becomes:
;;;
;;;     (add-user-lisp-to-path "yasnippet")
;;;
;;; The user documents directory can be made the initial buffer in case
;;; no command line arguments are passed in:
;;;
;;;   (if (eql (length command-line-args) 1)
;;;      ;; No files were passed in the command line.
;;;      (setq initial-buffer-choice user-documents-directory))
;;;
;;;
;;; Caveat Emptor:
;;;
;;; Variable setting and directory initialization were not properly tested.
;;; I have never tested setting previously the directories because the
;;; default results are satisfactory.
;;;
;;;
;;; History:
;;;
;;;  0.1.1: Francisco Miguel Colaço <francisco.col...@gmail.com>
;;;    Removed stale code;
;;;    Replaced eq by zerop in xdg-user-dir.
;;;  0.1: Francisco Miguel Colaço <francisco.col...@gmail.com>
;;;    Directory variables;
;;;    Functions to locate files;
;;;    add-to-path and add-user-lisp-to-path;
;;;    xdg-user-dir (depends on xdg-user-dir existing).
;;;
;;;
;;; Future work:
;;;
;;;   1. Make better docstrings (I may have assumed too much).
;;;   3. Add customize support.
;;;   3. Add more functions to cover the full standard.
;;;   4. Add more convenience functions (as needed by others).
;;;   5. Refactor the initialization of the variables.
;;;   6. Make it within the default emacs distribution.
;;;

(eval-when-compile
  (require 'cl))

;;; Directories definition.
(defvar user-emacs-config-directory nil
  "The directory where the emacs user configuration files are stored at.")


(defvar user-emacs-data-directory nil
  "The directory where the emacs user data and lisp files are stored at.

\\[user-emacs-directory] is set to this directory.")


(defvar user-emacs-cache-directory nil
  "The directory where the emacs user expendable files are stored at.

Files stored here should not be missed when deleted, apart a
temporary loss in speed.")


(defvar user-emacs-lisp-directory nil
  "The directory where the user lisp packages are stored at.

This directory is added to \\[load-path].")


(defvar user-documents-directory nil
  "The directory where the user stores his documents.")



(defun xdg-user-dir (dirname)
  "Given NAME, run 'xdg-user-dir NAME' and return the result in a string.

If the command fails, return NIL."
  (let ((command (concat "xdg-user-dir " dirname)))
    (if (zerop (shell-command command))
	(substring (shell-command-to-string command) 0 -1)
      nil)))


(defun locate-user-file (filename &optional type)
  "Given a file, locate it in the user files.

If TYPE is NIL or 'data, the file will be located in user-emacs-data-directory.

If 'config, it will be located in user-emacs-config-directory.

If 'cache, it will be located in user-emacs-cache-directory.

If 'lisp, it will be located in user-emacs-lisp-directory.

If 'documents, it will be located in user-documents-directory.

If the category is wrong, an error will be signaled.
"
  (expand-file-name filename
		    (case type
		      ((nil 'data) user-emacs-data-directory)
		      ('config user-emacs-config-directory)
		      ('lisp user-emacs-lisp-directory)
		      ('cache user-emacs-cache-directory)
		      ('documents user-documents-directory)
		      (t (error "The category %s is not valid" type)))))


(defun locate-user-config-file (filename)
  "Given a file, locate it in `user-emacs-config-directory`."
  (locate-user-file filename 'config))


(defun locate-user-lisp (filename)
  "Given a file, locate it in `user-emacs-lisp-directory`."
  (locate-user-file filename 'lisp))


(defun add-to-path (directory &optional append)
  "Given DIRECTORY, it it exists and is indeed a directory, add
it to `load-path`."
  (interactive "D")
  (if (file-directory-p directory)
      (add-to-list 'load-path directory append)
      (error "The directory \"%s\" does not exist or isn't a directory." directory)))


(defun add-user-lisp-to-path (directory &optional append)
  "Given DIRECTORY, it it exists and is indeed a directory, add
it to `load-path`."
  (interactive "D")
  (add-to-path (locate-user-lisp directory) append))


;; Set the default variables if they have no name.
(macrolet ((setq-if-null (variable value)
	     `(if (null ,variable)
		  (setf ,variable ,value)))
	   (getdir (variable fallback)
	     `(expand-file-name "emacs/" (or (getenv ,variable) ,fallback))))
  (setq-if-null user-emacs-config-directory (getdir "XDG_CONFIG_HOME" "~/.config/"))
  (setq-if-null user-emacs-data-directory (getdir "XDG_DATA_HOME" "~/.local/share/"))
  (setq-if-null user-emacs-cache-directory (getdir "XDG_CACHE_HOME" "~/.cache/"))
  (setq-if-null user-emacs-lisp-directory (expand-file-name "lisp" user-emacs-data-directory))
  (setq-if-null user-documents-directory (or (xdg-user-dir "DOCUMENTS") "~/Documents")))


;; Set the user-emacs-directory to user-emacs-data-directory.
(setf user-emacs-directory user-emacs-data-directory)


;; Add the user lisp directory to path.
(add-to-list 'load-path user-emacs-lisp-directory)


(provide 'xdg-paths)
