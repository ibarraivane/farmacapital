import { useCallback, useEffect, useRef, useState } from "react";
import { useMediaQuery } from "../hooks/useMediaQuery";

export function IconWell({ Icon, active, size = 15 }) {
  if (!Icon) return null;
  return (
    <span className={`fc-dash-tab-well${active ? " is-active" : ""}`}>
      <Icon size={size} strokeWidth={1.9} aria-hidden />
    </span>
  );
}

function enabledItems(items) {
  return items.filter((it) => !it.disabled);
}

/** Riel tipo shadcn/iOS. size md = sección; sm = vista (más ligero, sin well de fondo). */
export function SegmentedNav({
  items,
  value,
  onChange,
  ariaLabel,
  size = "md",
  activation,
  idPrefix,
  isMobile: isMobileProp,
  onReorder,
  dragRef,
}) {
  const mqMobile = useMediaQuery("(max-width: 768px)");
  const isMobile = isMobileProp ?? mqMobile;
  const resolvedActivation = activation ?? (size === "sm" ? "auto" : "manual");
  const railRef = useRef(null);
  const btnRefs = useRef({});
  const [hasMore, setHasMore] = useState(false);
  const [focusId, setFocusId] = useState(() => value || items.find((it) => !it.disabled)?.id);

  useEffect(() => {
    if (items.some((it) => it.id === value && !it.disabled)) setFocusId(value);
  }, [value, items]);

  const updateMore = useCallback(() => {
    const rail = railRef.current;
    if (!rail) return;
    setHasMore(rail.scrollWidth - rail.clientWidth - rail.scrollLeft > 4);
  }, []);

  useEffect(() => {
    updateMore();
    const rail = railRef.current;
    window.addEventListener("resize", updateMore);
    let ro;
    if (rail && typeof ResizeObserver !== "undefined") {
      ro = new ResizeObserver(updateMore);
      ro.observe(rail);
    }
    return () => {
      window.removeEventListener("resize", updateMore);
      ro?.disconnect();
    };
  }, [updateMore, items, value, size]);

  const activate = (id) => {
    const it = items.find((x) => x.id === id);
    if (!it || it.disabled || !onChange) return;
    onChange(id);
  };

  const focusEnabled = (id) => {
    setFocusId(id);
    const node = btnRefs.current[id];
    if (node) node.focus();
    if (resolvedActivation === "auto") activate(id);
  };

  const move = (delta) => {
    const enabled = enabledItems(items);
    if (!enabled.length) return;
    const from = Math.max(0, enabled.findIndex((it) => it.id === focusId));
    const next = enabled[(from + delta + enabled.length) % enabled.length];
    focusEnabled(next.id);
  };

  const onKeyDown = (e) => {
    if (e.key === "ArrowRight") { e.preventDefault(); move(1); return; }
    if (e.key === "ArrowLeft") { e.preventDefault(); move(-1); return; }
    if (e.key === "Home") {
      e.preventDefault();
      const first = enabledItems(items)[0];
      if (first) focusEnabled(first.id);
      return;
    }
    if (e.key === "End") {
      e.preventDefault();
      const en = enabledItems(items);
      if (en.length) focusEnabled(en[en.length - 1].id);
      return;
    }
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      activate(focusId);
    }
  };

  const iconSize = size === "sm" ? 13 : 15;
  const focusedDisabled = items.find((it) => it.id === focusId && it.disabled);

  return (
    <div className="fc-dash-seg-block">
      <div className={`fc-dash-seg-wrap${size === "sm" ? " fc-dash-seg-wrap--sm" : ""}${hasMore ? " has-more" : ""}`}>
        <div
          ref={railRef}
          className={`fc-dash-seg${size === "sm" ? " fc-dash-seg--sm" : ""}`}
          role="tablist"
          aria-label={ariaLabel}
          onScroll={updateMore}
          onKeyDown={onKeyDown}
        >
          {items.map((it) => {
            const active = value === it.id;
            const label = isMobile && it.labelMobile ? it.labelMobile : it.label;
            const tabId = idPrefix ? `${idPrefix}-tab-${it.id}` : undefined;
            const panelId = idPrefix ? `${idPrefix}-panel-${it.id}` : undefined;
            return (
              <div
                key={it.id}
                className="fc-dash-seg-item"
                onDragOver={(e) => { if (onReorder) e.preventDefault(); }}
                onDrop={(e) => {
                  if (!onReorder) return;
                  e.preventDefault();
                  const from = e.dataTransfer.getData("text/dashboard-tab") || dragRef?.current;
                  onReorder(from, it.id);
                  if (dragRef) dragRef.current = null;
                }}
              >
                {onReorder && (
                  <span
                    className="fc-dash-tab-move"
                    draggable
                    onDragStart={(e) => {
                      if (dragRef) dragRef.current = it.id;
                      e.dataTransfer.setData("text/dashboard-tab", it.id);
                      e.dataTransfer.effectAllowed = "move";
                    }}
                    onDragEnd={() => { if (dragRef) dragRef.current = null; }}
                    title="Arrastrar para reordenar"
                    aria-hidden
                  >⋮⋮</span>
                )}
                <button
                  id={tabId}
                  ref={(el) => { btnRefs.current[it.id] = el; }}
                  type="button"
                  role="tab"
                  aria-selected={active}
                  aria-controls={panelId}
                  aria-disabled={it.disabled ? "true" : undefined}
                  tabIndex={focusId === it.id ? 0 : -1}
                  title={it.title}
                  onClick={() => {
                    setFocusId(it.id);
                    if (it.disabled) return;
                    activate(it.id);
                  }}
                  className={`fc-dash-seg-tab${active ? " is-active" : ""}${it.Icon ? "" : " no-icon"}`}
                >
                  {it.Icon && <IconWell Icon={it.Icon} active={active && !it.disabled} size={iconSize} />}
                  {label}
                </button>
              </div>
            );
          })}
        </div>
      </div>
      {focusedDisabled?.title ? (
        <p className="fc-dash-tab-reason" role="note">{focusedDisabled.title}</p>
      ) : null}
    </div>
  );
}
