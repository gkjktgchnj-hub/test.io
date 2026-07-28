(function () {
  "use strict";

  var toggle = document.getElementById("navToggle");
  var close = document.getElementById("navClose");
  var nav = document.getElementById("mainNav");
  var scrim = document.getElementById("navScrim");

  function openNav() {
    nav.classList.add("open");
    scrim.classList.add("open");
    toggle.setAttribute("aria-expanded", "true");
    document.body.style.overflow = "hidden";
  }

  function closeAllDropdowns() {
    document.querySelectorAll(".has-dropdown.open").forEach(function (li) {
      li.classList.remove("open");
      var btn = li.querySelector(".nav-parent");
      if (btn) btn.setAttribute("aria-expanded", "false");
    });
  }

  function closeNav() {
    nav.classList.remove("open");
    scrim.classList.remove("open");
    toggle.setAttribute("aria-expanded", "false");
    document.body.style.overflow = "";
    closeAllDropdowns();
  }

  if (toggle && nav && scrim && close) {
    toggle.addEventListener("click", openNav);
    close.addEventListener("click", closeNav);
    scrim.addEventListener("click", closeNav);

    nav.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", closeNav);
    });

    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") closeNav();
    });
  }

  // Dropdown / submenu toggles (Bad & Sanitär, Heiztechnik, Aktuell, Über uns)
  document.querySelectorAll(".nav-parent").forEach(function (btn) {
    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      var li = btn.closest(".has-dropdown");
      var isOpen = li.classList.contains("open");
      document.querySelectorAll(".has-dropdown.open").forEach(function (other) {
        if (other !== li) {
          other.classList.remove("open");
          other.querySelector(".nav-parent").setAttribute("aria-expanded", "false");
        }
      });
      li.classList.toggle("open", !isOpen);
      btn.setAttribute("aria-expanded", String(!isOpen));
    });
  });

  document.addEventListener("click", function () {
    closeAllDropdowns();
  });

  // Only one FAQ item open at a time
  var faqItems = document.querySelectorAll(".faq-item");
  faqItems.forEach(function (item) {
    item.addEventListener("toggle", function () {
      if (item.open) {
        faqItems.forEach(function (other) {
          if (other !== item) other.open = false;
        });
      }
    });
  });
})();
