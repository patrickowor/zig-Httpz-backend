const AppRouterType = @import("../../app.zig").AppRouter;

const authRouters = @import("./auth/auth.controller.zig").authRouters;
const userRouters = @import("./user/user.controller.zig").userRouters;

// Export an array of AppRouter
pub const routers = authRouters ++ userRouters;
