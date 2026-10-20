// pone el modo oscuro si estaba guardado
var tema = localStorage.getItem("theme") || "light";
if (tema == "dark") {
   document.documentElement.setAttribute("data-theme", "dark");
}
