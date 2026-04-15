# OpenCode Instructions

This file contains high-signal context and conventions for AI agents working in this repository.

## Architecture & Frameworks
- **Framework**: Next.js 15.5 App Router. The core dashboard acts as an SPA mounted at `/` via `app/page.tsx` rendering `app/dashboard.tsx`.
- **Component Boundaries**: 
  - Generic UI components (Radix/shadcn) live in the root `components/ui/` directory.
  - Feature-specific and heavy layout sections (e.g. `productos-section.tsx`, `categorias-section.tsx`) live in `app/components/`.
- **Styling**: Tailwind CSS **v4** (`@tailwindcss/postcss`). There is no `tailwind.config.js/ts`. All custom theme variables and variants are located in `app/globals.css`. Do not attempt to modify a v3 config file.

## Database & Types (Supabase)
- **Supabase v2**: The Supabase client is initialized in `lib/supabase.ts`.
- **Manual Typings**: The database table types (`Producto`, `Categoria`, `Marca`, etc.) are **manually** defined and exported from `lib/supabase.ts`. Do not look for an auto-generated `database.types.ts` file. Always update the types directly in `lib/supabase.ts` when modifying columns.
- **State/Data Fetching**: The app uses a single global data fetching hook `useSupabaseData` (`app/hooks/use-supabase-data.ts`) to query Supabase and sync state across the dashboard components.

## Authentication
- **Auth Provider**: Clerk (`@clerk/nextjs`).
- **Routing**: Clerk handles the forms under `app/sign-in/` and `app/sign-up/`.
- **Middleware**: Route protection is managed by `middleware.ts` in the project root.

## Commands
- **Local Dev**: `npm run dev` 
- **Build**: `npm run build` (Always verify builds pass without TypeScript or ESLint errors before concluding features).