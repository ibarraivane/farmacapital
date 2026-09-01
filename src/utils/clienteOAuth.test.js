import {
  enabledSocialProviders,
  isOAuthCallbackLocation,
  SOCIAL_PROVIDERS,
} from "./clienteOAuth";

describe("clienteOAuth helpers", () => {
  const prev = process.env.REACT_APP_SOCIAL_LOGIN;

  afterEach(() => {
    if (prev === undefined) delete process.env.REACT_APP_SOCIAL_LOGIN;
    else process.env.REACT_APP_SOCIAL_LOGIN = prev;
    delete process.env.REACT_APP_OAUTH_PROVIDERS;
  });

  test("default providers = google + apple", () => {
    delete process.env.REACT_APP_SOCIAL_LOGIN;
    delete process.env.REACT_APP_OAUTH_PROVIDERS;
    const list = enabledSocialProviders();
    expect(list.map((p) => p.id)).toEqual(["google", "apple"]);
  });

  test("parsea lista coma-separada y filtra inválidos", () => {
    process.env.REACT_APP_SOCIAL_LOGIN = "google, apple, twitter, facebook";
    const list = enabledSocialProviders();
    expect(list.map((p) => p.id)).toEqual(["google", "facebook", "apple"]);
    expect(list.every((p) => SOCIAL_PROVIDERS.some((s) => s.id === p.id))).toBe(true);
  });

  test("detecta callback por path y query/hash", () => {
    expect(isOAuthCallbackLocation("/auth/callback", "", "")).toBe(true);
    expect(isOAuthCallbackLocation("/auth/callback/", "", "")).toBe(true);
    expect(isOAuthCallbackLocation("/login", "?oauth=1", "")).toBe(true);
    expect(isOAuthCallbackLocation("/", "?code=abc", "")).toBe(true);
    expect(isOAuthCallbackLocation("/", "", "#access_token=x")).toBe(true);
    expect(isOAuthCallbackLocation("/login", "", "")).toBe(false);
  });
});
