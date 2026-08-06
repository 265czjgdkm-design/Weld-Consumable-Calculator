(function () {
  var targets = document.querySelectorAll("[data-reveal]");
  if (!("IntersectionObserver" in window) || targets.length === 0) {
    return; // content is visible by default in CSS — nothing to do
  }

  // Only now do we opt into the hidden-until-revealed styles, so a slow or
  // failed script never leaves real content invisible.
  document.documentElement.classList.add("js-anim");

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
  );

  targets.forEach(function (el) {
    observer.observe(el);
  });

  // Safety net: force-reveal anything the observer hasn't caught yet after a
  // short delay (covers automated tools, unusual viewports, timing races).
  setTimeout(function () {
    document.querySelectorAll("[data-reveal]:not(.is-visible)").forEach(
      function (el) {
        el.classList.add("is-visible");
      }
    );
  }, 2000);
})();

(function () {
  var form = document.getElementById("notify-form");
  var status = document.getElementById("notify-status");
  if (!form || !status) return;

  form.addEventListener("submit", function (event) {
    event.preventDefault();
    status.textContent = "Sending…";
    status.className = "notify-status";

    fetch(form.action, {
      method: "POST",
      body: new FormData(form),
      headers: { Accept: "application/json" },
    })
      .then(function (response) {
        if (response.ok) {
          status.textContent = "You're on the list — we'll email you at launch.";
          status.className = "notify-status success";
          form.reset();
        } else {
          status.textContent = "Something went wrong. Try again in a moment.";
          status.className = "notify-status error";
        }
      })
      .catch(function () {
        status.textContent = "Something went wrong. Try again in a moment.";
        status.className = "notify-status error";
      });
  });
})();
